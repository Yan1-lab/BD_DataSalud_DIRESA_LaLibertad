/*
Proyecto: DataSalud La Libertad
Base de Datos Avanzadas y Big Data - CIIN1021P

Ejecucion recomendada:
1) Seccion 1: crear BD, esquemas y tablas.
2) Seccion 2: cargar STG.
3) Seccion 3: perfilar calidad.
4) Seccion 4: crear CORE y procedimientos.
5) Seccion 5: procesar La Libertad.
6) Seccion 6: triggers y pruebas.
7) Seccion 7: seguridad.
8) Seccion 8: rendimiento e indice.
9) Seccion 9: Data Warehouse.
10) Seccion 10: backup/restore.
*/

/* Alcance: SIEN-HIS Gestantes, SIEN-HIS Ninos y UBIGEO. CNV queda fuera del alcance. */

/* ============================================================
   1. BASE DE DATOS, ESQUEMAS Y TABLAS
   ============================================================ */
USE master;
GO

IF DB_ID(N'BD_DataSalud') IS NULL
BEGIN
    CREATE DATABASE BD_DataSalud;
END;
GO

USE BD_DataSalud;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'stg') EXEC(N'CREATE SCHEMA stg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'core') EXEC(N'CREATE SCHEMA core');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'audit') EXEC(N'CREATE SCHEMA audit');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dw') EXEC(N'CREATE SCHEMA dw');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'etl') EXEC(N'CREATE SCHEMA etl');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'sec') EXEC(N'CREATE SCHEMA sec');
GO

IF OBJECT_ID(N'audit.LogAuditoria', N'U') IS NULL
BEGIN
    CREATE TABLE audit.LogAuditoria
    (
        IdLog BIGINT IDENTITY(1,1) PRIMARY KEY,
        FechaHora DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        UsuarioSQL SYSNAME NOT NULL DEFAULT SUSER_SNAME(),
        TablaAfectada NVARCHAR(128) NOT NULL,
        Operacion NVARCHAR(20) NOT NULL,
        IdRegistro NVARCHAR(100) NULL,
        Detalle NVARCHAR(1000) NULL
    );
END;
GO

IF OBJECT_ID(N'etl.LogEjecucion', N'U') IS NULL
BEGIN
    CREATE TABLE etl.LogEjecucion
    (
        IdLogETL BIGINT IDENTITY(1,1) PRIMARY KEY,
        FechaInicio DATETIME2 NOT NULL,
        FechaFin DATETIME2 NULL,
        Proceso NVARCHAR(150) NOT NULL,
        FilasExtraidas BIGINT NULL,
        FilasTransformadas BIGINT NULL,
        FilasCargadas BIGINT NULL,
        Estado NVARCHAR(20) NOT NULL,
        Mensaje NVARCHAR(1000) NULL
    );
END;
GO

IF OBJECT_ID(N'etl.ControlCarga', N'U') IS NULL
BEGIN
    CREATE TABLE etl.ControlCarga
    (
        IdCarga BIGINT IDENTITY(1,1) PRIMARY KEY,
        FechaCarga DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        ArchivoOrigen NVARCHAR(500) NOT NULL,
        TablaDestino NVARCHAR(128) NOT NULL,
        FilasCargadas BIGINT NULL,
        Estado NVARCHAR(20) NOT NULL,
        Observacion NVARCHAR(1000) NULL
    );
END;
GO

IF OBJECT_ID(N'etl.PerfilCalidad', N'U') IS NULL
BEGIN
    CREATE TABLE etl.PerfilCalidad
    (
        IdPerfil BIGINT IDENTITY(1,1) PRIMARY KEY,
        FechaAnalisis DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        TablaOrigen NVARCHAR(128) NOT NULL,
        Campo NVARCHAR(128) NOT NULL,
        TipoProblema NVARCHAR(100) NOT NULL,
        RegistrosAfectados BIGINT NOT NULL,
        Detalle NVARCHAR(1000) NULL
    );
END;
GO

/* STG: se conserva el contenido de los CSV antes de limpiar */
IF OBJECT_ID(N'stg.GestantesCLAP', N'U') IS NULL
BEGIN
    CREATE TABLE stg.GestantesCLAP
    (
        sw NVARCHAR(50), Diresa NVARCHAR(150), Red NVARCHAR(150), Microred NVARCHAR(150), EESS NVARCHAR(500), Renipress NVARCHAR(50), Edad NVARCHAR(50), Fur NVARCHAR(50), Peso NVARCHAR(50), Talla NVARCHAR(50), Ppg NVARCHAR(50), Edad_Gest NVARCHAR(50), Tipo_Embarazo NVARCHAR(100), Ubigeo NVARCHAR(50), Departamento NVARCHAR(150), Provincia NVARCHAR(150), Distrito NVARCHAR(150), Localidad NVARCHAR(250), Altitud_Loc NVARCHAR(50), Hemoglobina NVARCHAR(50), FechaHemoglobina NVARCHAR(50), pais NVARCHAR(100), atencion_fecha NVARCHAR(50), fecha_nacimiento NVARCHAR(50), mes NVARCHAR(20), dias NVARCHAR(20), [año] NVARCHAR(20), UbigeoREN NVARCHAR(50), DepartamentoREN NVARCHAR(150), ProvinciaREN NVARCHAR(150), DistritoREN NVARCHAR(150), AlturaREN NVARCHAR(50), Dx_CLAP NVARCHAR(250)
    );
END;
GO

IF OBJECT_ID(N'stg.GestantesIMC', N'U') IS NULL
BEGIN
    CREATE TABLE stg.GestantesIMC
    (
        sw NVARCHAR(50), Diresa NVARCHAR(150), Red NVARCHAR(150), Microred NVARCHAR(150), EESS NVARCHAR(500), Renipress NVARCHAR(50), Edad NVARCHAR(50), Fur NVARCHAR(50), Peso NVARCHAR(50), Talla NVARCHAR(50), Ppg NVARCHAR(50), Edad_Gest NVARCHAR(50), Tipo_Embarazo NVARCHAR(100), Ubigeo NVARCHAR(50), Departamento NVARCHAR(150), Provincia NVARCHAR(150), Distrito NVARCHAR(150), Localidad NVARCHAR(250), Altitud_Loc NVARCHAR(50), Hemoglobina NVARCHAR(50), FechaHemoglobina NVARCHAR(50), pais NVARCHAR(100), atencion_fecha NVARCHAR(50), fecha_nacimiento NVARCHAR(50), mes NVARCHAR(20), dias NVARCHAR(20), [año] NVARCHAR(20), UbigeoREN NVARCHAR(50), DepartamentoREN NVARCHAR(150), ProvinciaREN NVARCHAR(150), DistritoREN NVARCHAR(150), AlturaREN NVARCHAR(50), IMCPpg NVARCHAR(250)
    );
END;
GO

IF OBJECT_ID(N'stg.GestantesIOM', N'U') IS NULL
BEGIN
    CREATE TABLE stg.GestantesIOM
    (
        sw NVARCHAR(50), Diresa NVARCHAR(150), Red NVARCHAR(150), Microred NVARCHAR(150), EESS NVARCHAR(500), Renipress NVARCHAR(50), Edad NVARCHAR(50), Fur NVARCHAR(50), Peso NVARCHAR(50), Talla NVARCHAR(50), Ppg NVARCHAR(50), Edad_Gest NVARCHAR(50), Ubigeo NVARCHAR(50), Departamento NVARCHAR(150), Provincia NVARCHAR(150), Distrito NVARCHAR(150), Localidad NVARCHAR(250), Altitud_Loc NVARCHAR(50), Hemoglobina NVARCHAR(50), FechaHemoglobina NVARCHAR(50), pais NVARCHAR(100), atencion_fecha NVARCHAR(50), fecha_nacimiento NVARCHAR(50), mes NVARCHAR(20), dias NVARCHAR(20), [año] NVARCHAR(20), UbigeoREN NVARCHAR(50), DepartamentoREN NVARCHAR(150), ProvinciaREN NVARCHAR(150), DistritoREN NVARCHAR(150), AlturaREN NVARCHAR(50), IOM_Menor157cm NVARCHAR(250), IOM_Mayor157cm NVARCHAR(250)
    );
END;
GO

IF OBJECT_ID(N'stg.NinosHB', N'U') IS NULL
BEGIN
    CREATE TABLE stg.NinosHB
    (
        sw NVARCHAR(50), Diresa NVARCHAR(150), Red NVARCHAR(150), Microred NVARCHAR(150), EESS NVARCHAR(500), Dpto_EESS NVARCHAR(150), Prov_EESS NVARCHAR(150), Dist_EESS NVARCHAR(150), Renipress NVARCHAR(50), FechaAtencion NVARCHAR(50), Pais NVARCHAR(100), Sexo NVARCHAR(20), FechaNacimiento NVARCHAR(50), EdadMeses NVARCHAR(50), UbigeoPN NVARCHAR(50), DepartamentoPN NVARCHAR(150), ProvinciaPN NVARCHAR(150), DistritoPN NVARCHAR(150), CentroPobladoPN NVARCHAR(250), Juntos NVARCHAR(50), SIS NVARCHAR(50), Pin NVARCHAR(50), Qaliwarma NVARCHAR(50), Hemoglobina NVARCHAR(50), FechaHemoglobina NVARCHAR(50), Cred NVARCHAR(50), Suplementacion NVARCHAR(50), Consejeria NVARCHAR(50), Sesion NVARCHAR(50), UbigeoREN NVARCHAR(50), DepartamentoREN NVARCHAR(150), ProvinciaREN NVARCHAR(150), DistritoREN NVARCHAR(150), AlturaREN NVARCHAR(50), Hbc NVARCHAR(50), Dx_anemia NVARCHAR(100)
    );
END;
GO

IF OBJECT_ID(N'stg.NinosPT', N'U') IS NULL
BEGIN
    CREATE TABLE stg.NinosPT
    (
        sw NVARCHAR(50), Diresa NVARCHAR(150), Red NVARCHAR(150), Microred NVARCHAR(150), EESS NVARCHAR(500), Dpto_EESS NVARCHAR(150), Prov_EESS NVARCHAR(150), Dist_EESS NVARCHAR(150), Renipress NVARCHAR(50), FechaAtencion NVARCHAR(50), Pais NVARCHAR(100), Sexo NVARCHAR(20), FechaNacimiento NVARCHAR(50), EdadMeses NVARCHAR(50), UbigeoPN NVARCHAR(50), DepartamentoPN NVARCHAR(150), ProvinciaPN NVARCHAR(150), DistritoPN NVARCHAR(150), CentroPobladoPN NVARCHAR(250), Juntos NVARCHAR(50), SIS NVARCHAR(50), Pin NVARCHAR(50), Qaliwarma NVARCHAR(50), Peso NVARCHAR(50), Talla NVARCHAR(50), PTZ NVARCHAR(50), ZTE NVARCHAR(50), ZPE NVARCHAR(50), Dx_PT NVARCHAR(100), Dx_TE NVARCHAR(100), Dx_PE NVARCHAR(100), Cred NVARCHAR(50), Suplementacion NVARCHAR(50), Consejeria NVARCHAR(50), Sesion NVARCHAR(50), UbigeoREN NVARCHAR(50), DepartamentoREN NVARCHAR(150), ProvinciaREN NVARCHAR(150), DistritoREN NVARCHAR(150), AlturaREN NVARCHAR(50)
    );
END;
GO

IF OBJECT_ID(N'stg.UbigeoRENIEC', N'U') IS NULL
BEGIN
    CREATE TABLE stg.UbigeoRENIEC
    (
        Ubigeo NVARCHAR(20), Distrito NVARCHAR(150), Provincia NVARCHAR(150), Departamento NVARCHAR(150), Poblacion NVARCHAR(50), Superficie NVARCHAR(50), Y NVARCHAR(50), X NVARCHAR(50)
    );
END;
GO

/* ============================================================
   2. CARGA COMPLETA A STG
   ============================================================ */
USE BD_DataSalud;
GO

TRUNCATE TABLE stg.GestantesCLAP;
TRUNCATE TABLE stg.GestantesIMC;
TRUNCATE TABLE stg.GestantesIOM;
TRUNCATE TABLE stg.NinosHB;
TRUNCATE TABLE stg.NinosPT;
TRUNCATE TABLE stg.UbigeoRENIEC;
TRUNCATE TABLE etl.ControlCarga;
GO

IF OBJECT_ID('tempdb..#ArchivosCarga') IS NOT NULL
    DROP TABLE #ArchivosCarga;

CREATE TABLE #ArchivosCarga
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TablaDestino SYSNAME NOT NULL,
    ArchivoOrigen NVARCHAR(500) NOT NULL
);
GO

DECLARE @Base NVARCHAR(500) =
    N'C:\Users\gameo\OneDrive\Desktop\db\db_proyecto\';


INSERT INTO #ArchivosCarga (TablaDestino, ArchivoOrigen)
SELECT
    N'stg.GestantesCLAP',
    @Base + N'BD SIEN-HIS Gestantes 2024\BD SIEN-HIS Gestantes 2024\CLAP\' + v.Nombre
FROM
(
    VALUES
    (N'Gestantes Amazonas.csv'),
    (N'Gestantes Ancash.csv'),
    (N'Gestantes Apurimac.csv'),
    (N'Gestantes Arequipa.csv'),
    (N'Gestantes Ayacucho.csv'),
    (N'Gestantes Cajamarca.csv'),
    (N'Gestantes Callao.csv'),
    (N'Gestantes Cusco.csv'),
    (N'Gestantes Huancavelica.csv'),
    (N'Gestantes Huanuco.csv'),
    (N'Gestantes Ica.csv'),
    (N'Gestantes Junin.csv'),
    (N'Gestantes La Libertad.csv'),
    (N'Gestantes Lambayeque.csv'),
    (N'Gestantes Lima Diris Centro.csv'),
    (N'Gestantes Lima Diris Este.csv'),
    (N'Gestantes Lima Diris Norte.csv'),
    (N'Gestantes Lima Diris Sur.csv'),
    (N'Gestantes Lima Provincias.csv'),
    (N'Gestantes Lima Region.csv'),
    (N'Gestantes Loreto.csv'),
    (N'Gestantes Madre De Dios.csv'),
    (N'Gestantes Moquegua.csv'),
    (N'Gestantes Pasco.csv'),
    (N'Gestantes Piura.csv'),
    (N'Gestantes Puno.csv'),
    (N'Gestantes San Martin.csv'),
    (N'Gestantes Tacna.csv'),
    (N'Gestantes Tumbes.csv'),
    (N'Gestantes Ucayali.csv')
) v(Nombre);


INSERT INTO #ArchivosCarga (TablaDestino, ArchivoOrigen)
SELECT
    N'stg.GestantesIMC',
    @Base + N'BD SIEN-HIS Gestantes 2024\BD SIEN-HIS Gestantes 2024\IMC\' + v.Nombre
FROM
(
    VALUES
    (N'Gestantes Amazonas.csv'),
    (N'Gestantes Ancash.csv'),
    (N'Gestantes Apurimac.csv'),
    (N'Gestantes Arequipa.csv'),
    (N'Gestantes Ayacucho.csv'),
    (N'Gestantes Cajamarca.csv'),
    (N'Gestantes Callao.csv'),
    (N'Gestantes Cusco.csv'),
    (N'Gestantes Huancavelica.csv'),
    (N'Gestantes Huanuco.csv'),
    (N'Gestantes Ica.csv'),
    (N'Gestantes Junin.csv'),
    (N'Gestantes La Libertad.csv'),
    (N'Gestantes Lambayeque.csv'),
    (N'Gestantes Lima Diris Centro.csv'),
    (N'Gestantes Lima Diris Este.csv'),
    (N'Gestantes Lima Diris Norte.csv'),
    (N'Gestantes Lima Diris Sur.csv'),
    (N'Gestantes Lima Provincias.csv'),
    (N'Gestantes Lima Region.csv'),
    (N'Gestantes Loreto.csv'),
    (N'Gestantes Madre De Dios.csv'),
    (N'Gestantes Moquegua.csv'),
    (N'Gestantes Pasco.csv'),
    (N'Gestantes Piura.csv'),
    (N'Gestantes Puno.csv'),
    (N'Gestantes San Martin.csv'),
    (N'Gestantes Tacna.csv'),
    (N'Gestantes Tumbes.csv'),
    (N'Gestantes Ucayali.csv')
) v(Nombre);


INSERT INTO #ArchivosCarga (TablaDestino, ArchivoOrigen)
SELECT
    N'stg.GestantesIOM',
    @Base + N'BD SIEN-HIS Gestantes 2024\BD SIEN-HIS Gestantes 2024\IOM\' + v.Nombre
FROM
(
    VALUES
    (N'Gestantes Amazonas.csv'),
    (N'Gestantes Ancash.csv'),
    (N'Gestantes Apurimac.csv'),
    (N'Gestantes Arequipa.csv'),
    (N'Gestantes Ayacucho.csv'),
    (N'Gestantes Cajamarca.csv'),
    (N'Gestantes Callao.csv'),
    (N'Gestantes Cusco.csv'),
    (N'Gestantes Huancavelica.csv'),
    (N'Gestantes Huanuco.csv'),
    (N'Gestantes Ica.csv'),
    (N'Gestantes Junin.csv'),
    (N'Gestantes La Libertad.csv'),
    (N'Gestantes Lambayeque.csv'),
    (N'Gestantes Lima Diris Centro.csv'),
    (N'Gestantes Lima Diris Este.csv'),
    (N'Gestantes Lima Diris Norte.csv'),
    (N'Gestantes Lima Diris Sur.csv'),
    (N'Gestantes Lima Provincias.csv'),
    (N'Gestantes Lima Region.csv'),
    (N'Gestantes Loreto.csv'),
    (N'Gestantes Madre De Dios.csv'),
    (N'Gestantes Moquegua.csv'),
    (N'Gestantes Pasco.csv'),
    (N'Gestantes Piura.csv'),
    (N'Gestantes Puno.csv'),
    (N'Gestantes San Martin.csv'),
    (N'Gestantes Tacna.csv'),
    (N'Gestantes Tumbes.csv'),
    (N'Gestantes Ucayali.csv')
) v(Nombre);


INSERT INTO #ArchivosCarga (TablaDestino, ArchivoOrigen)
SELECT
    N'stg.NinosHB',
    @Base + N'BD SIEN-HIS Niños 2024\BD SIEN-HIS Niños 2024\Hb\' + v.Nombre
FROM
(
    VALUES
    (N'Niños AMAZONAS.csv'),
    (N'Niños ANCASH.csv'),
    (N'Niños APURIMAC.csv'),
    (N'Niños AREQUIPA.csv'),
    (N'Niños AYACUCHO.csv'),
    (N'Niños CAJAMARCA.csv'),
    (N'Niños CALLAO.csv'),
    (N'Niños CUSCO.csv'),
    (N'Niños HUANCAVELICA.csv'),
    (N'Niños HUANUCO.csv'),
    (N'Niños ICA.csv'),
    (N'Niños JUNIN.csv'),
    (N'Niños LA LIBERTAD.csv'),
    (N'Niños LAMBAYEQUE.csv'),
    (N'Niños LIMA DIRIS CENTRO.csv'),
    (N'Niños LIMA DIRIS ESTE.csv'),
    (N'Niños LIMA DIRIS NORTE.csv'),
    (N'Niños LIMA DIRIS SUR.csv'),
    (N'Niños LIMA PROVINCIAS.csv'),
    (N'Niños LORETO.csv'),
    (N'Niños MADRE DE DIOS.csv'),
    (N'Niños MOQUEGUA.csv'),
    (N'Niños PASCO.csv'),
    (N'Niños PIURA.csv'),
    (N'Niños PUNO.csv'),
    (N'Niños SAN MARTIN.csv'),
    (N'Niños TACNA.csv'),
    (N'Niños TUMBES.csv'),
    (N'Niños UCAYALI.csv')
) v(Nombre);


INSERT INTO #ArchivosCarga (TablaDestino, ArchivoOrigen)
SELECT
    N'stg.NinosPT',
    @Base + N'BD SIEN-HIS Niños 2024\BD SIEN-HIS Niños 2024\Pt\' + v.Nombre
FROM
(
    VALUES
    (N'Niños AMAZONAS.csv'),
    (N'Niños ANCASH.csv'),
    (N'Niños APURIMAC.csv'),
    (N'Niños AREQUIPA.csv'),
    (N'Niños AYACUCHO.csv'),
    (N'Niños CAJAMARCA.csv'),
    (N'Niños CALLAO.csv'),
    (N'Niños CUSCO.csv'),
    (N'Niños HUANCAVELICA.csv'),
    (N'Niños HUANUCO.csv'),
    (N'Niños ICA.csv'),
    (N'Niños JUNIN.csv'),
    (N'Niños LA LIBERTAD.csv'),
    (N'Niños LAMBAYEQUE.csv'),
    (N'Niños LIMA DIRIS CENTRO.csv'),
    (N'Niños LIMA DIRIS ESTE.csv'),
    (N'Niños LIMA DIRIS NORTE.csv'),
    (N'Niños LIMA DIRIS SUR.csv'),
    (N'Niños LIMA PROVINCIAS.csv'),
    (N'Niños LORETO.csv'),
    (N'Niños MADRE DE DIOS.csv'),
    (N'Niños MOQUEGUA.csv'),
    (N'Niños PASCO.csv'),
    (N'Niños PIURA.csv'),
    (N'Niños PUNO.csv'),
    (N'Niños SAN MARTIN.csv'),
    (N'Niños TACNA.csv'),
    (N'Niños TUMBES.csv'),
    (N'Niños UCAYALI.csv')
) v(Nombre);


INSERT INTO #ArchivosCarga (TablaDestino, ArchivoOrigen)
VALUES
(
    N'stg.UbigeoRENIEC',
    @Base + N'geodir-ubigeo-reniec.csv'
);


DECLARE
    @Id INT,
    @Tabla SYSNAME,
    @Archivo NVARCHAR(500),
    @SQL NVARCHAR(MAX),
    @Filas BIGINT;


DECLARE c CURSOR LOCAL FAST_FORWARD FOR
SELECT
    Id,
    TablaDestino,
    ArchivoOrigen
FROM #ArchivosCarga
ORDER BY Id;


OPEN c;

FETCH NEXT FROM c INTO @Id, @Tabla, @Archivo;


WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY

        SET @Filas = 0;

        SET @SQL =
            N'BULK INSERT ' + @Tabla + N'
            FROM N''' + REPLACE(@Archivo, '''', '''''') + N'''
            WITH
            (
                FORMAT = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"'',
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0a'',
                CODEPAGE = ''65001'',
                TABLOCK
            );

            SET @Filas = @@ROWCOUNT;';


        EXEC sys.sp_executesql
            @SQL,
            N'@Filas BIGINT OUTPUT',
            @Filas = @Filas OUTPUT;


        INSERT INTO etl.ControlCarga
        (
            ArchivoOrigen,
            TablaDestino,
            FilasCargadas,
            Estado,
            Observacion
        )
        VALUES
        (
            @Archivo,
            @Tabla,
            @Filas,
            N'OK',
            N'Carga correcta'
        );

    END TRY

    BEGIN CATCH

        INSERT INTO etl.ControlCarga
        (
            ArchivoOrigen,
            TablaDestino,
            FilasCargadas,
            Estado,
            Observacion
        )
        VALUES
        (
            @Archivo,
            @Tabla,
            0,
            N'ERROR',
            ERROR_MESSAGE()
        );

    END CATCH;


    FETCH NEXT FROM c INTO @Id, @Tabla, @Archivo;
END;


CLOSE c;
DEALLOCATE c;
GO


SELECT
    TablaDestino,
    COUNT(*) AS ArchivosProcesados,
    SUM(CASE WHEN Estado = N'OK' THEN 1 ELSE 0 END) AS CargasOK,
    SUM(CASE WHEN Estado = N'ERROR' THEN 1 ELSE 0 END) AS CargasError,
    SUM(FilasCargadas) AS FilasCargadas
FROM etl.ControlCarga
GROUP BY TablaDestino
ORDER BY TablaDestino;
GO


SELECT
    N'GestantesCLAP' AS Tabla,
    COUNT_BIG(*) AS Registros
FROM stg.GestantesCLAP

UNION ALL

SELECT
    N'GestantesIMC',
    COUNT_BIG(*)
FROM stg.GestantesIMC

UNION ALL

SELECT
    N'GestantesIOM',
    COUNT_BIG(*)
FROM stg.GestantesIOM

UNION ALL

SELECT
    N'NinosHB',
    COUNT_BIG(*)
FROM stg.NinosHB

UNION ALL

SELECT
    N'NinosPT',
    COUNT_BIG(*)
FROM stg.NinosPT

UNION ALL

SELECT
    N'UbigeoRENIEC',
    COUNT_BIG(*)
FROM stg.UbigeoRENIEC;
GO

/* ============================================================
   3. PERFIL DE CALIDAD
   ============================================================ */
TRUNCATE TABLE etl.PerfilCalidad;
GO

INSERT INTO etl.PerfilCalidad (TablaOrigen, Campo, TipoProblema, RegistrosAfectados, Detalle)
SELECT N'stg.GestantesCLAP', N'Hemoglobina', N'Nulo/Vacio', COUNT_BIG(*), N'La hemoglobina no tiene valor'
FROM stg.GestantesCLAP WHERE NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NULL
UNION ALL
SELECT N'stg.GestantesCLAP', N'Ubigeo', N'Longitud incorrecta', COUNT_BIG(*), N'El UBIGEO no tiene 6 digitos'
FROM stg.GestantesCLAP WHERE NULLIF(LTRIM(RTRIM(Ubigeo)), N'') IS NOT NULL AND LEN(LTRIM(RTRIM(Ubigeo))) <> 6
UNION ALL
SELECT N'stg.GestantesCLAP', N'Hemoglobina', N'Fuera de rango', COUNT_BIG(*), N'Valor menor que 0 o mayor que 25'
FROM stg.GestantesCLAP WHERE TRY_CONVERT(decimal(10,2), REPLACE(NULLIF(LTRIM(RTRIM(Hemoglobina)), N''), N',', N'.')) NOT BETWEEN 0 AND 25
  AND NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NOT NULL
UNION ALL
SELECT N'stg.GestantesIMC', N'Peso', N'Nulo/Vacio', COUNT_BIG(*), N'El peso no tiene valor'
FROM stg.GestantesIMC WHERE NULLIF(LTRIM(RTRIM(Peso)), N'') IS NULL
UNION ALL
SELECT N'stg.GestantesIMC', N'Edad_Gest', N'Nulo/Vacio', COUNT_BIG(*), N'Edad gestacional no registrada'
FROM stg.GestantesIMC WHERE NULLIF(LTRIM(RTRIM(Edad_Gest)), N'') IS NULL
UNION ALL
SELECT N'stg.GestantesIOM', N'Hemoglobina', N'Nulo/Vacio', COUNT_BIG(*), N'La hemoglobina no tiene valor'
FROM stg.GestantesIOM WHERE NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NULL
UNION ALL
SELECT N'stg.NinosHB', N'UbigeoPN', N'Nulo/Vacio', COUNT_BIG(*), N'UBIGEO del paciente no registrado'
FROM stg.NinosHB WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NULL
UNION ALL
SELECT N'stg.NinosHB', N'Hemoglobina', N'Nulo/Vacio', COUNT_BIG(*), N'La hemoglobina no tiene valor'
FROM stg.NinosHB WHERE NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NULL
UNION ALL
SELECT N'stg.NinosHB', N'UbigeoPN', N'Longitud incorrecta', COUNT_BIG(*), N'El UBIGEO no tiene 6 digitos'
FROM stg.NinosHB WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NOT NULL AND LEN(LTRIM(RTRIM(UbigeoPN))) <> 6
UNION ALL
SELECT N'stg.NinosPT', N'UbigeoPN', N'Nulo/Vacio', COUNT_BIG(*), N'UBIGEO del paciente no registrado'
FROM stg.NinosPT WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NULL
UNION ALL
SELECT N'stg.NinosPT', N'Peso', N'Nulo/Vacio', COUNT_BIG(*), N'El peso no tiene valor'
FROM stg.NinosPT WHERE NULLIF(LTRIM(RTRIM(Peso)), N'') IS NULL
UNION ALL
SELECT N'stg.NinosPT', N'UbigeoPN', N'Longitud incorrecta', COUNT_BIG(*), N'El UBIGEO no tiene 6 digitos'
FROM stg.NinosPT WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NOT NULL AND LEN(LTRIM(RTRIM(UbigeoPN))) <> 6;
GO

SELECT TablaOrigen, Campo, TipoProblema, RegistrosAfectados, Detalle
FROM etl.PerfilCalidad
ORDER BY TablaOrigen, RegistrosAfectados DESC;
GO

GO

SELECT TablaOrigen, Campo, TipoProblema, RegistrosAfectados, Detalle
FROM etl.PerfilCalidad
ORDER BY TablaOrigen, RegistrosAfectados DESC;
GO

/* Perfil especifico de La Libertad */
SELECT N'Gestantes CLAP' AS Dataset, COUNT_BIG(*) AS Registros
FROM stg.GestantesCLAP WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'
UNION ALL
SELECT N'Gestantes IMC', COUNT_BIG(*)
FROM stg.GestantesIMC WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'
UNION ALL
SELECT N'Gestantes IOM', COUNT_BIG(*)
FROM stg.GestantesIOM WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'
UNION ALL
SELECT N'Ninos HB', COUNT_BIG(*)
FROM stg.NinosHB WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'
UNION ALL
SELECT N'Ninos PT', COUNT_BIG(*)
FROM stg.NinosPT WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD';
GO

/* ============================================================
   4. CORE Y FUNCION REUTILIZABLE
   ============================================================ */
IF OBJECT_ID(N'core.Gestantes', N'U') IS NULL
BEGIN
    CREATE TABLE core.Gestantes
    (
        IdGestante BIGINT IDENTITY(1,1) PRIMARY KEY,
        Fuente NVARCHAR(20) NOT NULL,
        Diresa NVARCHAR(150) NULL,
        Red NVARCHAR(150) NULL,
        Microred NVARCHAR(150) NULL,
        EESS NVARCHAR(500) NULL,
        Renipress NVARCHAR(50) NULL,
        Edad INT NULL,
        Fur DATE NULL,
        Peso DECIMAL(8,2) NULL,
        Talla DECIMAL(8,2) NULL,
        Ppg DECIMAL(8,2) NULL,
        EdadGest NVARCHAR(30) NULL,
        TipoEmbarazo NVARCHAR(100) NULL,
        Ubigeo CHAR(6) NULL,
        Departamento NVARCHAR(150) NULL,
        Provincia NVARCHAR(150) NULL,
        Distrito NVARCHAR(150) NULL,
        Localidad NVARCHAR(250) NULL,
        AltitudLoc DECIMAL(10,2) NULL,
        Hemoglobina DECIMAL(8,2) NULL,
        FechaHemoglobina DATE NULL,
        AtencionFecha DATE NULL,
        FechaNacimiento DATE NULL,
        Mes INT NULL,
        Dias INT NULL,
        Anio INT NULL,
        UbigeoREN CHAR(6) NULL,
        DepartamentoREN NVARCHAR(150) NULL,
        ProvinciaREN NVARCHAR(150) NULL,
        DistritoREN NVARCHAR(150) NULL,
        AlturaREN DECIMAL(10,2) NULL,
        IndicadorNutricional NVARCHAR(250) NULL,
        Diagnostico NVARCHAR(250) NULL,
        FechaCarga DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID(N'core.NinosHB', N'U') IS NULL
BEGIN
    CREATE TABLE core.NinosHB
    (
        IdNinoHB BIGINT IDENTITY(1,1) PRIMARY KEY,
        Diresa NVARCHAR(150) NULL,
        Red NVARCHAR(150) NULL,
        Microred NVARCHAR(150) NULL,
        EESS NVARCHAR(500) NULL,
        DptoEESS NVARCHAR(150) NULL,
        ProvEESS NVARCHAR(150) NULL,
        DistEESS NVARCHAR(150) NULL,
        Renipress NVARCHAR(50) NULL,
        FechaAtencion DATE NULL,
        Sexo NVARCHAR(20) NULL,
        FechaNacimiento DATE NULL,
        EdadMeses DECIMAL(10,2) NULL,
        UbigeoPN CHAR(6) NULL,
        DepartamentoPN NVARCHAR(150) NULL,
        ProvinciaPN NVARCHAR(150) NULL,
        DistritoPN NVARCHAR(150) NULL,
        CentroPobladoPN NVARCHAR(250) NULL,
        Hemoglobina DECIMAL(8,2) NULL,
        FechaHemoglobina DATE NULL,
        AlturaREN DECIMAL(10,2) NULL,
        Hbc DECIMAL(8,2) NULL,
        DxAnemia NVARCHAR(100) NULL,
        FechaCarga DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID(N'core.NinosPT', N'U') IS NULL
BEGIN
    CREATE TABLE core.NinosPT
    (
        IdNinoPT BIGINT IDENTITY(1,1) PRIMARY KEY,
        Diresa NVARCHAR(150) NULL,
        Red NVARCHAR(150) NULL,
        Microred NVARCHAR(150) NULL,
        EESS NVARCHAR(500) NULL,
        DptoEESS NVARCHAR(150) NULL,
        ProvEESS NVARCHAR(150) NULL,
        DistEESS NVARCHAR(150) NULL,
        Renipress NVARCHAR(50) NULL,
        FechaAtencion DATE NULL,
        Sexo NVARCHAR(20) NULL,
        FechaNacimiento DATE NULL,
        EdadMeses DECIMAL(10,2) NULL,
        UbigeoPN CHAR(6) NULL,
        DepartamentoPN NVARCHAR(150) NULL,
        ProvinciaPN NVARCHAR(150) NULL,
        DistritoPN NVARCHAR(150) NULL,
        CentroPobladoPN NVARCHAR(250) NULL,
        Peso DECIMAL(8,2) NULL,
        Talla DECIMAL(8,2) NULL,
        PTZ DECIMAL(8,3) NULL,
        ZTE DECIMAL(8,3) NULL,
        ZPE DECIMAL(8,3) NULL,
        DxPT NVARCHAR(100) NULL,
        DxTE NVARCHAR(100) NULL,
        DxPE NVARCHAR(100) NULL,
        FechaCarga DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

CREATE OR ALTER FUNCTION core.fn_NormalizarUbigeo
(
    @Ubigeo NVARCHAR(50)
)
RETURNS CHAR(6)
AS
BEGIN
    DECLARE @Valor NVARCHAR(50) = LTRIM(RTRIM(@Ubigeo));
    DECLARE @Resultado CHAR(6);

    IF @Valor = N'' OR @Valor = N'0' OR TRY_CONVERT(BIGINT, @Valor) IS NULL
        RETURN NULL;

    IF LEN(@Valor) = 5
        SET @Resultado = RIGHT(N'000000' + @Valor, 6);
    ELSE IF LEN(@Valor) = 6
        SET @Resultado = @Valor;
    ELSE
        RETURN NULL;

    RETURN @Resultado;
END;
GO

/* ============================================================
   5. PROCEDIMIENTOS DE PROCESAMIENTO
   ============================================================ */
CREATE OR ALTER PROCEDURE core.sp_ProcesarGestantes
    @Diresa NVARCHAR(150) = N'LA LIBERTAD'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @InicioTran BIT = 0;
    DECLARE @Inicio DATETIME2 = SYSDATETIME();
    DECLARE @Filas BIGINT = 0;

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRAN;
            SET @InicioTran = 1;
        END
        ELSE
            SAVE TRANSACTION SP_Gestantes;

        EXEC sys.sp_set_session_context @key = N'SIN_AUDITORIA_ETL', @value = 1;

        DELETE FROM core.Gestantes
        WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)));

        INSERT INTO core.Gestantes
        (
            Fuente,Diresa,Red,Microred,EESS,Renipress,Edad,Fur,Peso,Talla,Ppg,EdadGest,TipoEmbarazo,
            Ubigeo,Departamento,Provincia,Distrito,Localidad,AltitudLoc,Hemoglobina,FechaHemoglobina,
            AtencionFecha,FechaNacimiento,Mes,Dias,Anio,UbigeoREN,DepartamentoREN,ProvinciaREN,DistritoREN,
            AlturaREN,IndicadorNutricional,Diagnostico
        )
        SELECT N'CLAP', Diresa,Red,Microred,EESS,Renipress,
               CASE WHEN TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Edad)),N'')) BETWEEN 10 AND 70 THEN TRY_CONVERT(INT, Edad) END,
               COALESCE(TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(Fur)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),23)),
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Peso)),N''),N',',N'.')) BETWEEN 20 AND 250 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Peso,N',',N'.')) END,
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Talla)),N''),N',',N'.')) BETWEEN 50 AND 250 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Talla,N',',N'.')) END,
               TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Ppg)),N''),N',',N'.')),
               NULLIF(LTRIM(RTRIM(Edad_Gest)),N''),Tipo_Embarazo,core.fn_NormalizarUbigeo(Ubigeo),Departamento,Provincia,Distrito,Localidad,
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(Altitud_Loc)),N''),N',',N'.')),
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Hemoglobina)),N''),N',',N'.')) BETWEEN 0 AND 25 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Hemoglobina,N',',N'.')) END,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),23)),
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),23)),
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),23)),
               TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM(mes)),N'')), TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM(dias)),N'')), TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM([año])),N'')),
               core.fn_NormalizarUbigeo(UbigeoREN),DepartamentoREN,ProvinciaREN,DistritoREN,
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(AlturaREN)),N''),N',',N'.')),
               NULL,NULLIF(LTRIM(RTRIM(Dx_CLAP)),N'')
        FROM stg.GestantesCLAP
        WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)))

        UNION ALL

        SELECT N'IMC', Diresa,Red,Microred,EESS,Renipress,
               CASE WHEN TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Edad)),N'')) BETWEEN 10 AND 70 THEN TRY_CONVERT(INT, Edad) END,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),23)),
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Peso)),N''),N',',N'.')) BETWEEN 20 AND 250 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Peso,N',',N'.')) END,
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Talla)),N''),N',',N'.')) BETWEEN 50 AND 250 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Talla,N',',N'.')) END,
               TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Ppg)),N''),N',',N'.')),
               NULLIF(LTRIM(RTRIM(Edad_Gest)),N''),Tipo_Embarazo,core.fn_NormalizarUbigeo(Ubigeo),Departamento,Provincia,Distrito,Localidad,
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(Altitud_Loc)),N''),N',',N'.')),
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Hemoglobina)),N''),N',',N'.')) BETWEEN 0 AND 25 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Hemoglobina,N',',N'.')) END,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),23)),
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),23)),
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),23)),
               TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM(mes)),N'')),TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM(dias)),N'')),TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM([año])),N'')),
               core.fn_NormalizarUbigeo(UbigeoREN),DepartamentoREN,ProvinciaREN,DistritoREN,
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(AlturaREN)),N''),N',',N'.')),
               NULLIF(LTRIM(RTRIM(IMCPpg)),N''),NULL
        FROM stg.GestantesIMC
        WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)))

        UNION ALL

        SELECT N'IOM', Diresa,Red,Microred,EESS,Renipress,
               CASE WHEN TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Edad)),N'')) BETWEEN 10 AND 70 THEN TRY_CONVERT(INT, Edad) END,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(Fur)),N''),23)),
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Peso)),N''),N',',N'.')) BETWEEN 20 AND 250 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Peso,N',',N'.')) END,
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Talla)),N''),N',',N'.')) BETWEEN 50 AND 250 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Talla,N',',N'.')) END,
               TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Ppg)),N''),N',',N'.')),
               NULLIF(LTRIM(RTRIM(Edad_Gest)),N''),NULL,core.fn_NormalizarUbigeo(Ubigeo),Departamento,Provincia,Distrito,Localidad,
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(Altitud_Loc)),N''),N',',N'.')),
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Hemoglobina)),N''),N',',N'.')) BETWEEN 0 AND 25 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Hemoglobina,N',',N'.')) END,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),23)),
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(atencion_fecha)),N''),23)),
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(fecha_nacimiento)),N''),23)),
               TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM(mes)),N'')),TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM(dias)),N'')),TRY_CONVERT(INT,NULLIF(LTRIM(RTRIM([año])),N'')),
               core.fn_NormalizarUbigeo(UbigeoREN),DepartamentoREN,ProvinciaREN,DistritoREN,
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(AlturaREN)),N''),N',',N'.')),
               NULLIF(LTRIM(RTRIM(IOM_Menor157cm + CASE WHEN IOM_Mayor157cm IS NOT NULL THEN N' / ' + IOM_Mayor157cm ELSE N'' END)),N''),NULL
        FROM stg.GestantesIOM
        WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)));

        SET @Filas = @@ROWCOUNT;
        EXEC sys.sp_set_session_context @key = N'SIN_AUDITORIA_ETL', @value = 0;

        INSERT INTO audit.LogAuditoria (TablaAfectada, Operacion, Detalle)
        VALUES (N'core.Gestantes', N'ETL', CONCAT(N'Procesamiento de ', @Diresa, N'. Filas: ', @Filas));

        IF @InicioTran = 1 COMMIT;

        INSERT INTO etl.LogEjecucion (FechaInicio, FechaFin, Proceso, FilasExtraidas, FilasTransformadas, FilasCargadas, Estado, Mensaje)
        VALUES (@Inicio, SYSDATETIME(), N'core.sp_ProcesarGestantes', @Filas, @Filas, @Filas, N'OK', CONCAT(N'Diresa: ', @Diresa));
    END TRY
    BEGIN CATCH
        EXEC sys.sp_set_session_context @key = N'SIN_AUDITORIA_ETL', @value = 0;

        IF XACT_STATE() <> 0
        BEGIN
            IF @InicioTran = 1
                ROLLBACK;
            ELSE IF XACT_STATE() = 1
                ROLLBACK TRANSACTION SP_Gestantes;
            ELSE
                ROLLBACK;
        END;

        INSERT INTO audit.LogAuditoria (TablaAfectada, Operacion, Detalle)
        VALUES (N'core.Gestantes', N'ERROR', ERROR_MESSAGE());

        INSERT INTO etl.LogEjecucion (FechaInicio, FechaFin, Proceso, FilasExtraidas, FilasTransformadas, FilasCargadas, Estado, Mensaje)
        VALUES (@Inicio, SYSDATETIME(), N'core.sp_ProcesarGestantes', @Filas, 0, 0, N'ERROR', ERROR_MESSAGE());

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE core.sp_ProcesarNinos
    @Diresa NVARCHAR(150) = N'LA LIBERTAD'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @InicioTran BIT = 0;
    DECLARE @Inicio DATETIME2 = SYSDATETIME();
    DECLARE @FilasHB BIGINT = 0, @FilasPT BIGINT = 0;

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRAN;
            SET @InicioTran = 1;
        END
        ELSE
            SAVE TRANSACTION SP_Ninos;

        EXEC sys.sp_set_session_context @key = N'SIN_AUDITORIA_ETL', @value = 1;

        DELETE FROM core.NinosHB WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)));
        DELETE FROM core.NinosPT WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)));

        INSERT INTO core.NinosHB
        (
            Diresa,Red,Microred,EESS,DptoEESS,ProvEESS,DistEESS,Renipress,FechaAtencion,Sexo,FechaNacimiento,
            EdadMeses,UbigeoPN,DepartamentoPN,ProvinciaPN,DistritoPN,CentroPobladoPN,Hemoglobina,FechaHemoglobina,AlturaREN,Hbc,DxAnemia
        )
        SELECT Diresa,Red,Microred,EESS,Dpto_EESS,Prov_EESS,Dist_EESS,Renipress,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaAtencion)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaAtencion)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaAtencion)),N''),23)),
               Sexo,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaNacimiento)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaNacimiento)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaNacimiento)),N''),23)),
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(EdadMeses)),N''),N',',N'.')),
               core.fn_NormalizarUbigeo(UbigeoPN),DepartamentoPN,ProvinciaPN,DistritoPN,CentroPobladoPN,
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Hemoglobina)),N''),N',',N'.')) BETWEEN 0 AND 25 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Hemoglobina,N',',N'.')) END,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaHemoglobina)),N''),23)),
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(AlturaREN)),N''),N',',N'.')),
               TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Hbc)),N''),N',',N'.')),Dx_anemia
        FROM stg.NinosHB
        WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)));
        SET @FilasHB = @@ROWCOUNT;

        INSERT INTO core.NinosPT
        (
            Diresa,Red,Microred,EESS,DptoEESS,ProvEESS,DistEESS,Renipress,FechaAtencion,Sexo,FechaNacimiento,
            EdadMeses,UbigeoPN,DepartamentoPN,ProvinciaPN,DistritoPN,CentroPobladoPN,Peso,Talla,PTZ,ZTE,ZPE,DxPT,DxTE,DxPE
        )
        SELECT Diresa,Red,Microred,EESS,Dpto_EESS,Prov_EESS,Dist_EESS,Renipress,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaAtencion)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaAtencion)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaAtencion)),N''),23)),
               Sexo,
               COALESCE(TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaNacimiento)),N''),101),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaNacimiento)),N''),103),TRY_CONVERT(DATE,NULLIF(LTRIM(RTRIM(FechaNacimiento)),N''),23)),
               TRY_CONVERT(DECIMAL(10,2),REPLACE(NULLIF(LTRIM(RTRIM(EdadMeses)),N''),N',',N'.')),
               core.fn_NormalizarUbigeo(UbigeoPN),DepartamentoPN,ProvinciaPN,DistritoPN,CentroPobladoPN,
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Peso)),N''),N',',N'.')) BETWEEN 0 AND 200 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Peso,N',',N'.')) END,
               CASE WHEN TRY_CONVERT(DECIMAL(8,2),REPLACE(NULLIF(LTRIM(RTRIM(Talla)),N''),N',',N'.')) BETWEEN 0 AND 250 THEN TRY_CONVERT(DECIMAL(8,2),REPLACE(Talla,N',',N'.')) END,
               TRY_CONVERT(DECIMAL(8,3),REPLACE(NULLIF(LTRIM(RTRIM(PTZ)),N''),N',',N'.')),
               TRY_CONVERT(DECIMAL(8,3),REPLACE(NULLIF(LTRIM(RTRIM(ZTE)),N''),N',',N'.')),
               TRY_CONVERT(DECIMAL(8,3),REPLACE(NULLIF(LTRIM(RTRIM(ZPE)),N''),N',',N'.')),
               Dx_PT,Dx_TE,Dx_PE
        FROM stg.NinosPT
        WHERE UPPER(LTRIM(RTRIM(Diresa))) = UPPER(LTRIM(RTRIM(@Diresa)));
        SET @FilasPT = @@ROWCOUNT;

        EXEC sys.sp_set_session_context @key = N'SIN_AUDITORIA_ETL', @value = 0;

        INSERT INTO audit.LogAuditoria (TablaAfectada, Operacion, Detalle)
        VALUES (N'core.NinosHB', N'ETL', CONCAT(N'Procesamiento de ', @Diresa, N'. Filas: ', @FilasHB)),
               (N'core.NinosPT', N'ETL', CONCAT(N'Procesamiento de ', @Diresa, N'. Filas: ', @FilasPT));

        IF @InicioTran = 1 COMMIT;

        INSERT INTO etl.LogEjecucion (FechaInicio,FechaFin,Proceso,FilasExtraidas,FilasTransformadas,FilasCargadas,Estado,Mensaje)
        VALUES (@Inicio,SYSDATETIME(),N'core.sp_ProcesarNinos',@FilasHB+@FilasPT,@FilasHB+@FilasPT,@FilasHB+@FilasPT,N'OK',CONCAT(N'Diresa: ',@Diresa));
    END TRY
    BEGIN CATCH
        EXEC sys.sp_set_session_context @key = N'SIN_AUDITORIA_ETL', @value = 0;
        IF XACT_STATE() <> 0
        BEGIN
            IF @InicioTran = 1 ROLLBACK;
            ELSE IF XACT_STATE() = 1 ROLLBACK TRANSACTION SP_Ninos;
            ELSE ROLLBACK;
        END;

        INSERT INTO audit.LogAuditoria (TablaAfectada, Operacion, Detalle)
        VALUES (N'core.Ninos', N'ERROR', ERROR_MESSAGE());

        INSERT INTO etl.LogEjecucion (FechaInicio,FechaFin,Proceso,FilasExtraidas,FilasTransformadas,FilasCargadas,Estado,Mensaje)
        VALUES (@Inicio,SYSDATETIME(),N'core.sp_ProcesarNinos',@FilasHB+@FilasPT,0,0,N'ERROR',ERROR_MESSAGE());

        THROW;
    END CATCH;
END;
GO

/* Ejecutar para La Libertad */
EXEC core.sp_ProcesarGestantes N'LA LIBERTAD';
EXEC core.sp_ProcesarNinos N'LA LIBERTAD';
GO

/* ============================================================
   6. TRIGGERS Y PRUEBAS
   ============================================================ */

-- Trigger de auditoría
CREATE OR ALTER TRIGGER core.trg_NinosHB_Auditoria
ON core.NinosHB
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(TRY_CONVERT(INT, SESSION_CONTEXT(N'SIN_AUDITORIA_ETL')), 0) = 1
        RETURN;

    IF EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO audit.LogAuditoria
            (TablaAfectada, Operacion, IdRegistro, Detalle)
        SELECT
            N'core.NinosHB',
            N'UPDATE',
            CONVERT(NVARCHAR(100), i.IdNinoHB),
            N'Registro actualizado'
        FROM inserted i;
    END
    ELSE IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO audit.LogAuditoria
            (TablaAfectada, Operacion, IdRegistro, Detalle)
        SELECT
            N'core.NinosHB',
            N'INSERT',
            CONVERT(NVARCHAR(100), i.IdNinoHB),
            N'Registro insertado'
        FROM inserted i;
    END
    ELSE
    BEGIN
        INSERT INTO audit.LogAuditoria
            (TablaAfectada, Operacion, IdRegistro, Detalle)
        SELECT
            N'core.NinosHB',
            N'DELETE',
            CONVERT(NVARCHAR(100), d.IdNinoHB),
            N'Registro eliminado'
        FROM deleted d;
    END
END;
GO


-- Trigger para validar datos de gestantes
CREATE OR ALTER TRIGGER core.trg_Gestantes_Integridad
ON core.Gestantes
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE
            (Edad IS NOT NULL AND (Edad < 10 OR Edad > 70))
            OR (Peso IS NOT NULL AND (Peso < 20 OR Peso > 250))
            OR (Talla IS NOT NULL AND (Talla < 50 OR Talla > 250))
            OR (Hemoglobina IS NOT NULL AND (Hemoglobina < 0 OR Hemoglobina > 25))
            OR (Ubigeo IS NOT NULL AND LEN(Ubigeo) <> 6)
    )
    BEGIN
        THROW 51001,
            N'Registro rechazado: no cumple las reglas basicas de integridad.',
            1;
    END;

    IF ISNULL(TRY_CONVERT(INT, SESSION_CONTEXT(N'SIN_AUDITORIA_ETL')), 0) = 0
    BEGIN
        INSERT INTO audit.LogAuditoria
            (TablaAfectada, Operacion, IdRegistro, Detalle)
        SELECT
            N'core.Gestantes',
            N'VALIDACION',
            CONVERT(NVARCHAR(100), i.IdGestante),
            N'Registro validado por trigger'
        FROM inserted i;
    END
END;
GO


-- Prueba del trigger de auditoría
DECLARE @IdPrueba BIGINT;

INSERT INTO core.NinosHB
    (Diresa, EESS, Renipress, Sexo, EdadMeses, Hemoglobina)
VALUES
    (N'PRUEBA', N'EESS PRUEBA', N'999999', N'F', 24, 12.0);

SET @IdPrueba = SCOPE_IDENTITY();

DELETE FROM core.NinosHB
WHERE IdNinoHB = @IdPrueba;
GO

SELECT TOP 20
    *
FROM audit.LogAuditoria
ORDER BY IdLog DESC;
GO


-- Prueba del trigger de integridad
INSERT INTO core.Gestantes
(
    Fuente,
    Edad,
    Peso,
    Talla,
    Hemoglobina,
    Ubigeo
)
VALUES
(
    N'PRUEBA',
    5,
    10,
    30,
    40,
    N'123'
);
GO


-- Prueba transaccional
BEGIN TRY
    BEGIN TRANSACTION;

    SAVE TRANSACTION PruebaSavepoint;

    INSERT INTO core.NinosHB
        (Diresa, EESS, Renipress, Sexo, EdadMeses, Hemoglobina)
    VALUES
        (N'PRUEBA_TRANSACCION', N'EESS TEST', N'999998', N'M', 36, 11.5);

    ROLLBACK TRANSACTION PruebaSavepoint;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;
END CATCH;
GO

/* ============================================================
   7. SEGURIDAD
   ============================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_DataSalud_Admin')
    CREATE ROLE rol_DataSalud_Admin;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_DataSalud_Analista')
    CREATE ROLE rol_DataSalud_Analista;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_DataSalud_Auditor')
    CREATE ROLE rol_DataSalud_Auditor;
GO

GRANT CONTROL ON DATABASE::BD_DataSalud TO rol_DataSalud_Admin;

GRANT SELECT ON SCHEMA::dw TO rol_DataSalud_Analista;
GRANT SELECT ON SCHEMA::core TO rol_DataSalud_Analista;
GRANT EXECUTE ON SCHEMA::core TO rol_DataSalud_Analista;
DENY INSERT, UPDATE, DELETE ON SCHEMA::core TO rol_DataSalud_Analista;
DENY SELECT ON SCHEMA::stg TO rol_DataSalud_Analista;

GRANT SELECT ON SCHEMA::audit TO rol_DataSalud_Auditor;
GRANT SELECT ON SCHEMA::dw TO rol_DataSalud_Auditor;
GRANT SELECT ON SCHEMA::etl TO rol_DataSalud_Auditor;
DENY INSERT, UPDATE, DELETE ON SCHEMA::audit TO rol_DataSalud_Auditor;
GO

/* ============================================================
   8. RENDIMIENTO E INDICE
   ============================================================ */
SELECT COUNT_BIG(*) AS RegistrosCoreGestantes FROM core.Gestantes;
SELECT COUNT_BIG(*) AS RegistrosCoreNinosHB FROM core.NinosHB;
SELECT COUNT_BIG(*) AS RegistrosCoreNinosPT FROM core.NinosPT;
GO

/* Medicion antes del indice */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Diresa, DistritoPN, COUNT_BIG(*) AS Registros, AVG(Hemoglobina) AS PromedioHb
FROM core.NinosHB
WHERE UbigeoPN = '130101'
GROUP BY Diresa, DistritoPN;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'core.NinosHB')
      AND name = N'IX_NinosHB_UbigeoPN'
)
BEGIN
    CREATE INDEX IX_NinosHB_UbigeoPN
    ON core.NinosHB (UbigeoPN)
    INCLUDE (Diresa,DistritoPN,Hemoglobina);
END;
GO

/* Medicion despues del indice */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Diresa, DistritoPN, COUNT_BIG(*) AS Registros, AVG(Hemoglobina) AS PromedioHb
FROM core.NinosHB
WHERE UbigeoPN = '130101'
GROUP BY Diresa, DistritoPN;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* Activar Include Actual Execution Plan (Ctrl+M) antes de ejecutar esta consulta */
SELECT Diresa, DistritoPN, COUNT_BIG(*) AS Registros, AVG(Hemoglobina) AS PromedioHb
FROM core.NinosHB
WHERE UbigeoPN = '130101'
GROUP BY Diresa, DistritoPN;
GO

/* ============================================================
   9. DATA WAREHOUSE - MODELO ESTRELLA
   ============================================================ */
IF OBJECT_ID(N'dw.DimFecha', N'U') IS NULL
BEGIN
    CREATE TABLE dw.DimFecha
    (
        FechaKey INT PRIMARY KEY,
        Fecha DATE NOT NULL UNIQUE,
        Anio INT NOT NULL,
        Mes INT NOT NULL,
        NombreMes NVARCHAR(20) NOT NULL,
        Trimestre INT NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dw.DimUbicacion', N'U') IS NULL
BEGIN
    CREATE TABLE dw.DimUbicacion
    (
        UbicacionKey INT IDENTITY(1,1) PRIMARY KEY,
        Ubigeo CHAR(6) NULL,
        Diresa NVARCHAR(150) NULL,
        Departamento NVARCHAR(150) NULL,
        Provincia NVARCHAR(150) NULL,
        Distrito NVARCHAR(150) NULL
    );
END;
GO

IF OBJECT_ID(N'dw.DimEstablecimiento', N'U') IS NULL
BEGIN
    CREATE TABLE dw.DimEstablecimiento
    (
        EstablecimientoKey INT IDENTITY(1,1) PRIMARY KEY,
        Renipress NVARCHAR(50) NULL,
        EESS NVARCHAR(500) NULL,
        Red NVARCHAR(150) NULL,
        Microred NVARCHAR(150) NULL,
        Departamento NVARCHAR(150) NULL,
        Provincia NVARCHAR(150) NULL,
        Distrito NVARCHAR(150) NULL
    );
END;
GO

IF OBJECT_ID(N'dw.DimTipoEvaluacion', N'U') IS NULL
BEGIN
    CREATE TABLE dw.DimTipoEvaluacion
    (
        TipoEvaluacionKey INT IDENTITY(1,1) PRIMARY KEY,
        Codigo NVARCHAR(30) NOT NULL UNIQUE,
        Descripcion NVARCHAR(150) NOT NULL,
        Poblacion NVARCHAR(50) NOT NULL,
        Fuente NVARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID(N'dw.FactEvaluacionSalud', N'U') IS NULL
BEGIN
    CREATE TABLE dw.FactEvaluacionSalud
    (
        FactKey BIGINT IDENTITY(1,1) PRIMARY KEY,
        FechaKey INT NULL,
        UbicacionKey INT NULL,
        EstablecimientoKey INT NULL,
        TipoEvaluacionKey INT NOT NULL,
        Edad DECIMAL(10,2) NULL,
        Sexo NVARCHAR(20) NULL,
        Hemoglobina DECIMAL(8,2) NULL,
        Peso DECIMAL(8,2) NULL,
        Talla DECIMAL(8,2) NULL,
        PTZ DECIMAL(8,3) NULL,
        ZTE DECIMAL(8,3) NULL,
        ZPE DECIMAL(8,3) NULL,
        Diagnostico NVARCHAR(250) NULL,
        FechaCarga DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

MERGE dw.DimTipoEvaluacion AS T
USING
(
    VALUES
    (N'GEST_CLAP',N'Control CLAP de gestante',N'Gestantes',N'SIEN-HIS 2024'),
    (N'GEST_IMC',N'Evaluacion IMC de gestante',N'Gestantes',N'SIEN-HIS 2024'),
    (N'GEST_IOM',N'Evaluacion IOM de gestante',N'Gestantes',N'SIEN-HIS 2024'),
    (N'NINO_HB',N'Evaluacion de hemoglobina en nino',N'Ninos',N'SIEN-HIS 2024'),
    (N'NINO_PT',N'Evaluacion peso/talla en nino',N'Ninos',N'SIEN-HIS 2024')
) AS S(Codigo,Descripcion,Poblacion,Fuente)
ON T.Codigo = S.Codigo
WHEN MATCHED THEN UPDATE SET Descripcion=S.Descripcion,Poblacion=S.Poblacion,Fuente=S.Fuente
WHEN NOT MATCHED THEN INSERT (Codigo,Descripcion,Poblacion,Fuente) VALUES (S.Codigo,S.Descripcion,S.Poblacion,S.Fuente);
GO

/* Dimensiones */
INSERT INTO dw.DimFecha (FechaKey,Fecha,Anio,Mes,NombreMes,Trimestre)
SELECT DISTINCT
    CONVERT(INT,CONVERT(CHAR(8),G.Fecha,112)),
    G.Fecha,
    YEAR(G.Fecha),MONTH(G.Fecha),DATENAME(MONTH,G.Fecha),DATEPART(QUARTER,G.Fecha)
FROM
(
    SELECT AtencionFecha AS Fecha FROM core.Gestantes WHERE AtencionFecha IS NOT NULL
    UNION
    SELECT FechaAtencion FROM core.NinosHB WHERE FechaAtencion IS NOT NULL
    UNION
    SELECT FechaAtencion FROM core.NinosPT WHERE FechaAtencion IS NOT NULL
) G
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.DimFecha D
    WHERE D.Fecha = G.Fecha
);
GO

INSERT INTO dw.DimUbicacion (Ubigeo,Diresa,Departamento,Provincia,Distrito)
SELECT DISTINCT Ubigeo,Diresa,Departamento,Provincia,Distrito
FROM core.Gestantes G
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.DimUbicacion D
    WHERE ISNULL(D.Ubigeo,'') = ISNULL(G.Ubigeo,'')
      AND ISNULL(D.Diresa,'') = ISNULL(G.Diresa,'')
      AND ISNULL(D.Distrito,'') = ISNULL(G.Distrito,'')
);

INSERT INTO dw.DimUbicacion (Ubigeo,Diresa,Departamento,Provincia,Distrito)
SELECT DISTINCT UbigeoPN,Diresa,DepartamentoPN,ProvinciaPN,DistritoPN
FROM core.NinosHB G
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.DimUbicacion D
    WHERE ISNULL(D.Ubigeo,'') = ISNULL(G.UbigeoPN,'')
      AND ISNULL(D.Diresa,'') = ISNULL(G.Diresa,'')
      AND ISNULL(D.Distrito,'') = ISNULL(G.DistritoPN,'')
);

INSERT INTO dw.DimUbicacion (Ubigeo,Diresa,Departamento,Provincia,Distrito)
SELECT DISTINCT UbigeoPN,Diresa,DepartamentoPN,ProvinciaPN,DistritoPN
FROM core.NinosPT G
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.DimUbicacion D
    WHERE ISNULL(D.Ubigeo,'') = ISNULL(G.UbigeoPN,'')
      AND ISNULL(D.Diresa,'') = ISNULL(G.Diresa,'')
      AND ISNULL(D.Distrito,'') = ISNULL(G.DistritoPN,'')
);
GO

INSERT INTO dw.DimEstablecimiento (Renipress,EESS,Red,Microred,Departamento,Provincia,Distrito)
SELECT DISTINCT Renipress,EESS,Red,Microred,Departamento,Provincia,Distrito
FROM core.Gestantes G
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.DimEstablecimiento D
    WHERE ISNULL(D.Renipress,'') = ISNULL(G.Renipress,'') AND ISNULL(D.EESS,'') = ISNULL(G.EESS,'')
);

INSERT INTO dw.DimEstablecimiento (Renipress,EESS,Red,Microred,Departamento,Provincia,Distrito)
SELECT DISTINCT Renipress,EESS,Red,Microred,DptoEESS,ProvEESS,DistEESS
FROM core.NinosHB G
WHERE NOT EXISTS
(
    SELECT 1 FROM dw.DimEstablecimiento D
    WHERE ISNULL(D.Renipress,'') = ISNULL(G.Renipress,'') AND ISNULL(D.EESS,'') = ISNULL(G.EESS,'')
);
GO

/* Carga de hechos. Se limpia solo el hecho para permitir reprocesarlo. */
DELETE FROM dw.FactEvaluacionSalud;
GO

INSERT INTO dw.FactEvaluacionSalud
(
    FechaKey,UbicacionKey,EstablecimientoKey,TipoEvaluacionKey,Edad,Sexo,Hemoglobina,Peso,Talla,PTZ,ZTE,ZPE,Diagnostico
)
SELECT F.FechaKey,U.UbicacionKey,E.EstablecimientoKey,T.TipoEvaluacionKey,
       G.Edad,NULL,G.Hemoglobina,G.Peso,G.Talla,NULL,NULL,NULL,G.Diagnostico
FROM core.Gestantes G
JOIN dw.DimTipoEvaluacion T ON T.Codigo = CASE G.Fuente WHEN N'CLAP' THEN N'GEST_CLAP' WHEN N'IMC' THEN N'GEST_IMC' ELSE N'GEST_IOM' END
LEFT JOIN dw.DimFecha F ON F.Fecha = G.AtencionFecha
LEFT JOIN dw.DimUbicacion U ON U.Ubigeo = G.Ubigeo AND U.Diresa = G.Diresa AND ISNULL(U.Distrito,'') = ISNULL(G.Distrito,'')
LEFT JOIN dw.DimEstablecimiento E ON ISNULL(E.Renipress,'') = ISNULL(G.Renipress,'') AND ISNULL(E.EESS,'') = ISNULL(G.EESS,'');

INSERT INTO dw.FactEvaluacionSalud
(
    FechaKey,UbicacionKey,EstablecimientoKey,TipoEvaluacionKey,Edad,Sexo,Hemoglobina,Peso,Talla,PTZ,ZTE,ZPE,Diagnostico
)
SELECT F.FechaKey,U.UbicacionKey,E.EstablecimientoKey,T.TipoEvaluacionKey,
       N.EdadMeses/12.0,N.Sexo,N.Hemoglobina,NULL,NULL,NULL,NULL,NULL,N.DxAnemia
FROM core.NinosHB N
JOIN dw.DimTipoEvaluacion T ON T.Codigo = N'NINO_HB'
LEFT JOIN dw.DimFecha F ON F.Fecha = N.FechaAtencion
LEFT JOIN dw.DimUbicacion U ON U.Ubigeo = N.UbigeoPN AND U.Diresa = N.Diresa AND ISNULL(U.Distrito,'') = ISNULL(N.DistritoPN,'')
LEFT JOIN dw.DimEstablecimiento E ON ISNULL(E.Renipress,'') = ISNULL(N.Renipress,'') AND ISNULL(E.EESS,'') = ISNULL(N.EESS,'');

INSERT INTO dw.FactEvaluacionSalud
(
    FechaKey,UbicacionKey,EstablecimientoKey,TipoEvaluacionKey,Edad,Sexo,Hemoglobina,Peso,Talla,PTZ,ZTE,ZPE,Diagnostico
)
SELECT F.FechaKey,U.UbicacionKey,E.EstablecimientoKey,T.TipoEvaluacionKey,
       N.EdadMeses/12.0,N.Sexo,NULL,N.Peso,N.Talla,N.PTZ,N.ZTE,N.ZPE,
       CONCAT(N.DxPT,N' | ',N.DxTE,N' | ',N.DxPE)
FROM core.NinosPT N
JOIN dw.DimTipoEvaluacion T ON T.Codigo = N'NINO_PT'
LEFT JOIN dw.DimFecha F ON F.Fecha = N.FechaAtencion
LEFT JOIN dw.DimUbicacion U ON U.Ubigeo = N.UbigeoPN AND U.Diresa = N.Diresa AND ISNULL(U.Distrito,'') = ISNULL(N.DistritoPN,'')
LEFT JOIN dw.DimEstablecimiento E ON ISNULL(E.Renipress,'') = ISNULL(N.Renipress,'') AND ISNULL(E.EESS,'') = ISNULL(N.EESS,'');
GO

IF OBJECT_ID(N'dw.vw_KPIsSalud', N'V') IS NOT NULL DROP VIEW dw.vw_KPIsSalud;
GO
CREATE VIEW dw.vw_KPIsSalud
AS
SELECT
    T.Codigo,
    T.Descripcion,
    U.Departamento,
    U.Provincia,
    U.Distrito,
    COUNT_BIG(*) AS Evaluaciones,
    AVG(F.Hemoglobina) AS PromedioHemoglobina,
    AVG(F.Peso) AS PromedioPeso,
    AVG(F.Talla) AS PromedioTalla
FROM dw.FactEvaluacionSalud F
JOIN dw.DimTipoEvaluacion T ON T.TipoEvaluacionKey = F.TipoEvaluacionKey
LEFT JOIN dw.DimUbicacion U ON U.UbicacionKey = F.UbicacionKey
GROUP BY T.Codigo,T.Descripcion,U.Departamento,U.Provincia,U.Distrito;
GO

SELECT TOP 30 *
FROM dw.vw_KPIsSalud
ORDER BY Evaluaciones DESC;
GO

/* ============================================================
   10. BACKUP Y RESTORE DE PRUEBA
   Se dejan listos, pero el restore no se ejecuta solo.
   ============================================================ */
DECLARE @BackupPath NVARCHAR(4000), @BackupFile NVARCHAR(4000), @SQLBackup NVARCHAR(MAX);
SET @BackupPath = CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultBackupPath'));

IF @BackupPath IS NULL
    THROW 51010, N'No se pudo obtener la carpeta predeterminada de backups de SQL Server.', 1;

IF RIGHT(@BackupPath,1) NOT IN ('\','/') SET @BackupPath += N'\';
SET @BackupFile = @BackupPath + N'BD_DataSalud_FULL.bak';

SET @SQLBackup = N'BACKUP DATABASE BD_DataSalud TO DISK = N''' + REPLACE(@BackupFile,'''','''''') + N''' WITH INIT, COMPRESSION, CHECKSUM, STATS = 10;';
EXEC sys.sp_executesql @SQLBackup;

RESTORE VERIFYONLY FROM DISK = @BackupFile;
GO

/*
Restore de prueba: ejecutar manualmente cuando se necesite la evidencia.

DECLARE @BackupFile NVARCHAR(4000) = CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultBackupPath'));
IF RIGHT(@BackupFile,1) NOT IN ('\','/') SET @BackupFile += N'\';
SET @BackupFile += N'BD_DataSalud_FULL.bak';

IF DB_ID(N'BD_DataSalud_RestorePrueba') IS NOT NULL
BEGIN
    ALTER DATABASE BD_DataSalud_RestorePrueba SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BD_DataSalud_RestorePrueba;
END;

CREATE TABLE #ArchivosRestore
(
    LogicalName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    [Type] CHAR(1),
    FileGroupName NVARCHAR(128),
    Size NUMERIC(20,0),
    MaxSize NUMERIC(20,0),
    FileID BIGINT,
    CreateLSN NUMERIC(25,0),
    DropLSN NUMERIC(25,0),
    UniqueID UNIQUEIDENTIFIER,
    ReadOnlyLSN NUMERIC(25,0),
    ReadWriteLSN NUMERIC(25,0),
    BackupSizeInBytes BIGINT,
    SourceBlockSize INT,
    FileGroupID INT,
    LogGroupGUID UNIQUEIDENTIFIER,
    DifferentialBaseLSN NUMERIC(25,0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32),
    SnapshotURL NVARCHAR(360)
);

DECLARE @SQLRestore NVARCHAR(MAX);
SET @SQLRestore = N'RESTORE FILELISTONLY FROM DISK = N''' + REPLACE(@BackupFile,'''','''''') + N'''';
INSERT INTO #ArchivosRestore EXEC sys.sp_executesql @SQLRestore;

DECLARE @DataPath NVARCHAR(4000) = CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultDataPath'));
DECLARE @LogPath NVARCHAR(4000) = CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultLogPath'));
IF RIGHT(@DataPath,1) NOT IN ('\','/') SET @DataPath += N'\';
IF RIGHT(@LogPath,1) NOT IN ('\','/') SET @LogPath += N'\';

SELECT @SQLRestore = N'RESTORE DATABASE BD_DataSalud_RestorePrueba FROM DISK = N''' + REPLACE(@BackupFile,'''','''''') + N''' WITH ' +
STRING_AGG(N'MOVE N''' + REPLACE(LogicalName,'''','''''') + N''' TO N''' +
    REPLACE(CASE WHEN [Type] = 'L' THEN @LogPath ELSE @DataPath END +
    REVERSE(LEFT(REVERSE(PhysicalName),CHARINDEX(N'\\',REVERSE(PhysicalName))-1)),'''','''''') + N'''', N', ')
FROM #ArchivosRestore;

EXEC sys.sp_executesql @SQLRestore;

DROP TABLE #ArchivosRestore;

SELECT name, state_desc
FROM sys.databases
WHERE name = N'BD_DataSalud_RestorePrueba';
*/
GO

/* ============================================================
   CONSULTAS FINALES DE CONTROL
   ============================================================ */
SELECT N'STG Gestantes CLAP' AS Tabla, COUNT_BIG(*) AS Registros FROM stg.GestantesCLAP
UNION ALL SELECT N'STG Gestantes IMC', COUNT_BIG(*) FROM stg.GestantesIMC
UNION ALL SELECT N'STG Gestantes IOM', COUNT_BIG(*) FROM stg.GestantesIOM
UNION ALL SELECT N'STG Ninos HB', COUNT_BIG(*) FROM stg.NinosHB
UNION ALL SELECT N'STG Ninos PT', COUNT_BIG(*) FROM stg.NinosPT
UNION ALL SELECT N'STG UBIGEO', COUNT_BIG(*) FROM stg.UbigeoRENIEC
UNION ALL SELECT N'CORE Gestantes', COUNT_BIG(*) FROM core.Gestantes
UNION ALL SELECT N'CORE Ninos HB', COUNT_BIG(*) FROM core.NinosHB
UNION ALL SELECT N'CORE Ninos PT', COUNT_BIG(*) FROM core.NinosPT
UNION ALL SELECT N'DW FactEvaluacionSalud', COUNT_BIG(*) FROM dw.FactEvaluacionSalud;
GO

SELECT TOP 20 * FROM etl.ControlCarga ORDER BY IdCarga DESC;
SELECT TOP 20 * FROM etl.LogEjecucion ORDER BY IdLogETL DESC;
SELECT TOP 20 * FROM audit.LogAuditoria ORDER BY IdLog DESC;
GO


/* ============================================================
   PERFIL DE CALIDAD
   ============================================================ */
USE BD_DataSalud;
GO

TRUNCATE TABLE etl.PerfilCalidad;
GO


/* Gestantes CLAP */

INSERT INTO etl.PerfilCalidad
(
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
)
SELECT
    N'stg.GestantesCLAP',
    N'Hemoglobina',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'La hemoglobina no tiene valor'
FROM stg.GestantesCLAP
WHERE NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NULL

UNION ALL

SELECT
    N'stg.GestantesCLAP',
    N'Ubigeo',
    N'Longitud incorrecta',
    COUNT_BIG(*),
    N'El UBIGEO no tiene 6 digitos'
FROM stg.GestantesCLAP
WHERE NULLIF(LTRIM(RTRIM(Ubigeo)), N'') IS NOT NULL
  AND LEN(LTRIM(RTRIM(Ubigeo))) <> 6

UNION ALL

SELECT
    N'stg.GestantesCLAP',
    N'Hemoglobina',
    N'Fuera de rango',
    COUNT_BIG(*),
    N'Valor fuera del rango permitido'
FROM stg.GestantesCLAP
WHERE NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NOT NULL
  AND TRY_CONVERT(DECIMAL(10,2),
      REPLACE(LTRIM(RTRIM(Hemoglobina)), N',', N'.'))
      NOT BETWEEN 0 AND 25;


/* Gestantes IMC */

INSERT INTO etl.PerfilCalidad
(
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
)
SELECT
    N'stg.GestantesIMC',
    N'Peso',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'El peso no tiene valor'
FROM stg.GestantesIMC
WHERE NULLIF(LTRIM(RTRIM(Peso)), N'') IS NULL

UNION ALL

SELECT
    N'stg.GestantesIMC',
    N'Edad_Gest',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'Edad gestacional no registrada'
FROM stg.GestantesIMC
WHERE NULLIF(LTRIM(RTRIM(Edad_Gest)), N'') IS NULL

UNION ALL

SELECT
    N'stg.GestantesIMC',
    N'Ubigeo',
    N'Longitud incorrecta',
    COUNT_BIG(*),
    N'El UBIGEO no tiene 6 digitos'
FROM stg.GestantesIMC
WHERE NULLIF(LTRIM(RTRIM(Ubigeo)), N'') IS NOT NULL
  AND LEN(LTRIM(RTRIM(Ubigeo))) <> 6;


/* Gestantes IOM */

INSERT INTO etl.PerfilCalidad
(
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
)
SELECT
    N'stg.GestantesIOM',
    N'Hemoglobina',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'La hemoglobina no tiene valor'
FROM stg.GestantesIOM
WHERE NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NULL

UNION ALL

SELECT
    N'stg.GestantesIOM',
    N'Ubigeo',
    N'Longitud incorrecta',
    COUNT_BIG(*),
    N'El UBIGEO no tiene 6 digitos'
FROM stg.GestantesIOM
WHERE NULLIF(LTRIM(RTRIM(Ubigeo)), N'') IS NOT NULL
  AND LEN(LTRIM(RTRIM(Ubigeo))) <> 6;


/* Niños HB */

INSERT INTO etl.PerfilCalidad
(
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
)
SELECT
    N'stg.NinosHB',
    N'UbigeoPN',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'UBIGEO del paciente no registrado'
FROM stg.NinosHB
WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NULL

UNION ALL

SELECT
    N'stg.NinosHB',
    N'Hemoglobina',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'La hemoglobina no tiene valor'
FROM stg.NinosHB
WHERE NULLIF(LTRIM(RTRIM(Hemoglobina)), N'') IS NULL

UNION ALL

SELECT
    N'stg.NinosHB',
    N'UbigeoPN',
    N'Longitud incorrecta',
    COUNT_BIG(*),
    N'El UBIGEO no tiene 6 digitos'
FROM stg.NinosHB
WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NOT NULL
  AND LEN(LTRIM(RTRIM(UbigeoPN))) <> 6;


/* Niños Peso/Talla */

INSERT INTO etl.PerfilCalidad
(
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
)
SELECT
    N'stg.NinosPT',
    N'UbigeoPN',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'UBIGEO del paciente no registrado'
FROM stg.NinosPT
WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NULL

UNION ALL

SELECT
    N'stg.NinosPT',
    N'Peso',
    N'Nulo/Vacio',
    COUNT_BIG(*),
    N'El peso no tiene valor'
FROM stg.NinosPT
WHERE NULLIF(LTRIM(RTRIM(Peso)), N'') IS NULL

UNION ALL

SELECT
    N'stg.NinosPT',
    N'UbigeoPN',
    N'Longitud incorrecta',
    COUNT_BIG(*),
    N'El UBIGEO no tiene 6 digitos'
FROM stg.NinosPT
WHERE NULLIF(LTRIM(RTRIM(UbigeoPN)), N'') IS NOT NULL
  AND LEN(LTRIM(RTRIM(UbigeoPN))) <> 6;
GO


/* Duplicados completos */

INSERT INTO etl.PerfilCalidad
(
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
)
SELECT
    N'stg.NinosHB',
    N'Registro completo',
    N'Duplicado',
    COUNT_BIG(*) - COUNT_BIG(DISTINCT
        CONCAT(
            Diresa,'|',EESS,'|',Renipress,'|',Sexo,'|',
            FechaAtencion,'|',FechaNacimiento,'|',
            EdadMeses,'|',UbigeoPN,'|',Hemoglobina
        )
    ),
    N'Registros repetidos considerando los principales campos'
FROM stg.NinosHB;

INSERT INTO etl.PerfilCalidad
(
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
)
SELECT
    N'stg.NinosPT',
    N'Registro completo',
    N'Duplicado',
    COUNT_BIG(*) - COUNT_BIG(DISTINCT
        CONCAT(
            Diresa,'|',EESS,'|',Renipress,'|',Sexo,'|',
            FechaAtencion,'|',FechaNacimiento,'|',
            EdadMeses,'|',UbigeoPN,'|',Peso,'|',Talla
        )
    ),
    N'Registros repetidos considerando los principales campos'
FROM stg.NinosPT;
GO


/* Resultado general */

SELECT
    TablaOrigen,
    Campo,
    TipoProblema,
    RegistrosAfectados,
    Detalle
FROM etl.PerfilCalidad
WHERE RegistrosAfectados > 0
ORDER BY
    RegistrosAfectados DESC,
    TablaOrigen;
GO


/* Registros de La Libertad */

SELECT
    N'Gestantes CLAP' AS Dataset,
    COUNT_BIG(*) AS Registros
FROM stg.GestantesCLAP
WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'

UNION ALL

SELECT
    N'Gestantes IMC',
    COUNT_BIG(*)
FROM stg.GestantesIMC
WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'

UNION ALL

SELECT
    N'Gestantes IOM',
    COUNT_BIG(*)
FROM stg.GestantesIOM
WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'

UNION ALL

SELECT
    N'Ninos HB',
    COUNT_BIG(*)
FROM stg.NinosHB
WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD'

UNION ALL

SELECT
    N'Ninos PT',
    COUNT_BIG(*)
FROM stg.NinosPT
WHERE UPPER(LTRIM(RTRIM(Diresa))) = N'LA LIBERTAD';
GO