import csv
import pyodbc
from datetime import datetime


ruta_csv = r"C:\Users\gameo\OneDrive\Desktop\db\db_proyecto\BD SIEN-HIS Niños 2024\BD SIEN-HIS Niños 2024\Hb\Niños LA LIBERTAD.csv"

inicio = datetime.now()


def limpiar_texto(valor):
    if valor is None:
        return None

    valor = str(valor).strip()

    return valor if valor != "" else None


def convertir_fecha(valor):
    valor = limpiar_texto(valor)

    if valor is None:
        return None

    formatos = [
        "%m/%d/%Y",
        "%d/%m/%Y",
        "%Y-%m-%d"
    ]

    for formato in formatos:
        try:
            return datetime.strptime(valor, formato).date()
        except ValueError:
            pass

    return None


def convertir_decimal(valor):
    valor = limpiar_texto(valor)

    if valor is None:
        return None

    try:
        return float(valor.replace(",", "."))
    except ValueError:
        return None


try:

    # ============================================================
    # 1. EXTRACCION
    # ============================================================

    filas = []

    with open(
        ruta_csv,
        "r",
        encoding="utf-8-sig",
        newline=""
    ) as archivo:

        lector = csv.DictReader(archivo)

        for fila in lector:
            filas.append(fila)

    filas_extraidas = len(filas)


    # ============================================================
    # 2. TRANSFORMACION
    # ============================================================

    filas_limpias = []
    claves_vistas = set()

    for fila in filas:

        fila["Diresa"] = limpiar_texto(fila.get("Diresa"))
        fila["EESS"] = limpiar_texto(fila.get("EESS"))
        fila["Renipress"] = limpiar_texto(fila.get("Renipress"))
        fila["Sexo"] = limpiar_texto(fila.get("Sexo"))

        fila["UbigeoPN"] = limpiar_texto(fila.get("UbigeoPN"))

        if fila["UbigeoPN"]:
            ubigeo = fila["UbigeoPN"].replace(".0", "")

            if ubigeo.isdigit():
                fila["UbigeoPN"] = ubigeo.zfill(6)
            else:
                fila["UbigeoPN"] = None

        fila["DepartamentoPN"] = limpiar_texto(
            fila.get("DepartamentoPN")
        )

        fila["ProvinciaPN"] = limpiar_texto(
            fila.get("ProvinciaPN")
        )

        fila["DistritoPN"] = limpiar_texto(
            fila.get("DistritoPN")
        )

        fila["CentroPobladoPN"] = limpiar_texto(
            fila.get("CentroPobladoPN")
        )

        fila["Dx_anemia"] = limpiar_texto(
            fila.get("Dx_anemia")
        )

        # Fechas
        fila["FechaAtencion"] = convertir_fecha(
            fila.get("FechaAtencion")
        )

        fila["FechaNacimiento"] = convertir_fecha(
            fila.get("FechaNacimiento")
        )

        fila["FechaHemoglobina"] = convertir_fecha(
            fila.get("FechaHemoglobina")
        )

        # Numericos
        fila["EdadMeses"] = convertir_decimal(
            fila.get("EdadMeses")
        )

        fila["Hemoglobina"] = convertir_decimal(
            fila.get("Hemoglobina")
        )

        # Eliminar filas totalmente vacias
        if not any(valor is not None for valor in fila.values()):
            continue

        # Eliminar duplicados
        clave = (
            fila.get("Diresa"),
            fila.get("EESS"),
            fila.get("Renipress"),
            fila.get("Sexo"),
            fila.get("FechaAtencion"),
            fila.get("FechaNacimiento"),
            fila.get("EdadMeses"),
            fila.get("UbigeoPN"),
            fila.get("Hemoglobina")
        )

        if clave in claves_vistas:
            continue

        claves_vistas.add(clave)

        filas_limpias.append(fila)


    filas_transformadas = len(filas_limpias)


    # ============================================================
    # 3. CONEXION A SQL SERVER
    # ============================================================

    drivers = pyodbc.drivers()

    if "ODBC Driver 18 for SQL Server" in drivers:
        driver = "ODBC Driver 18 for SQL Server"

    elif "ODBC Driver 17 for SQL Server" in drivers:
        driver = "ODBC Driver 17 for SQL Server"

    else:
        raise Exception(
            "No se encontró ODBC Driver 17 o 18 para SQL Server."
        )


    conexion = pyodbc.connect(
        f"DRIVER={{{driver}}};"
        "SERVER=KB;"
        "DATABASE=BD_DataSalud;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    cursor = conexion.cursor()


    # ============================================================
    # 4. LIMPIAR CARGAS ANTERIORES
    # ============================================================

    cursor.execute(
        "TRUNCATE TABLE etl.NinosHB_Python;"
    )

    cursor.execute(
        "DELETE FROM dw.FactNinosHB_ETL;"
    )


    # ============================================================
    # 5. CARGA A TABLA ETL
    # ============================================================

    sql = """
    INSERT INTO etl.NinosHB_Python
    (
        Diresa,
        EESS,
        Renipress,
        Sexo,
        FechaAtencion,
        FechaNacimiento,
        EdadMeses,
        UbigeoPN,
        DepartamentoPN,
        ProvinciaPN,
        DistritoPN,
        CentroPobladoPN,
        Hemoglobina,
        FechaHemoglobina,
        DxAnemia
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """


    datos = []

    for fila in filas_limpias:

        datos.append(
            (
                fila.get("Diresa"),
                fila.get("EESS"),
                fila.get("Renipress"),
                fila.get("Sexo"),
                fila.get("FechaAtencion"),
                fila.get("FechaNacimiento"),
                fila.get("EdadMeses"),
                fila.get("UbigeoPN"),
                fila.get("DepartamentoPN"),
                fila.get("ProvinciaPN"),
                fila.get("DistritoPN"),
                fila.get("CentroPobladoPN"),
                fila.get("Hemoglobina"),
                fila.get("FechaHemoglobina"),
                fila.get("Dx_anemia")
            )
        )


    cursor.fast_executemany = True
    cursor.executemany(sql, datos)

    filas_cargadas = len(datos)

    conexion.commit()


    # ============================================================
    # 6. CARGA AL DW
    # ============================================================

    sql_fact = """
    INSERT INTO dw.FactNinosHB_ETL
    (
        FechaKey,
        UbicacionKey,
        EstablecimientoKey,
        TipoEvaluacionKey,
        Edad,
        Sexo,
        Hemoglobina,
        Diagnostico
    )
    SELECT
        F.FechaKey,
        U.UbicacionKey,
        E.EstablecimientoKey,
        T.TipoEvaluacionKey,
        N.EdadMeses / 12.0,
        N.Sexo,
        N.Hemoglobina,
        N.DxAnemia
    FROM etl.NinosHB_Python N

    CROSS APPLY
    (
        SELECT TOP 1 TipoEvaluacionKey
        FROM dw.DimTipoEvaluacion
        WHERE Codigo = N'NINO_HB'
    ) T

    LEFT JOIN dw.DimFecha F
        ON F.Fecha = N.FechaAtencion

    OUTER APPLY
    (
	SELECT TOP 1 UbicacionKey
	FROM dw.DimUbicacion
	WHERE ISNULL(Ubigeo, '') = ISNULL(N.UbigeoPN, '')
          AND ISNULL(Diresa, '') = ISNULL(N.Diresa, '')
          AND ISNULL(Distrito, '') = ISNULL(N.DistritoPN, '')
        ORDER BY UbicacionKey
    ) U

    OUTER APPLY
    (
        SELECT TOP 1 EstablecimientoKey
        FROM dw.DimEstablecimiento
        WHERE ISNULL(Renipress, '') = ISNULL(N.Renipress, '')
          AND ISNULL(EESS, '') = ISNULL(N.EESS, '')
        ORDER BY EstablecimientoKey
    ) E;
    """


    cursor.execute(sql_fact)

    conexion.commit()


    # ============================================================
    # 7. CONTAR CARGA FINAL
    # ============================================================

    cursor.execute(
        "SELECT COUNT_BIG(*) FROM dw.FactNinosHB_ETL"
    )

    filas_dw = cursor.fetchone()[0]


    # ============================================================
    # 8. LOG DE EJECUCION
    # ============================================================

    fin = datetime.now()

    cursor.execute(
        """
        INSERT INTO etl.LogEjecucion
        (
            FechaInicio,
            FechaFin,
            Proceso,
            FilasExtraidas,
            FilasTransformadas,
            FilasCargadas,
            Estado,
            Mensaje
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,

        inicio,
        fin,
        "ETL Python - Ninos HB La Libertad",
        filas_extraidas,
        filas_transformadas,
        filas_dw,
        "OK",
        "Extraccion, limpieza, normalizacion y carga realizadas correctamente"
    )

    conexion.commit()


    cursor.close()
    conexion.close()


    print()
    print("====================================")
    print("ETL EJECUTADO CORRECTAMENTE")
    print("====================================")
    print("Filas extraidas:", filas_extraidas)
    print("Filas transformadas:", filas_transformadas)
    print("Filas cargadas:", filas_cargadas)
    print("Filas en DW:", filas_dw)
    print("Inicio:", inicio)
    print("Fin:", fin)
    print("====================================")


except Exception as error:

    print()
    print("====================================")
    print("ERROR EN EL ETL")
    print("====================================")
    print(error)