--CORRECCION DE dw.FactEvaluacionSalud
USE BD_DataSalud;
GO

SELECT
    'CORE Gestantes' AS Tabla,
    COUNT_BIG(*) AS Registros
FROM core.Gestantes

UNION ALL

SELECT
    'CORE NinosHB',
    COUNT_BIG(*)
FROM core.NinosHB

UNION ALL

SELECT
    'CORE NinosPT',
    COUNT_BIG(*)
FROM core.NinosPT

UNION ALL

SELECT
    'DW FactEvaluacionSalud',
    COUNT_BIG(*)
FROM dw.FactEvaluacionSalud;
GO

--LA LIBERTAD
SELECT
    'Gestantes' AS Tabla,
    COUNT_BIG(*) AS Registros
FROM core.Gestantes
WHERE UPPER(LTRIM(RTRIM(Diresa))) = 'LA LIBERTAD'

UNION ALL

SELECT
    'NinosHB',
    COUNT_BIG(*)
FROM core.NinosHB
WHERE UPPER(LTRIM(RTRIM(Diresa))) = 'LA LIBERTAD'

UNION ALL

SELECT
    'NinosPT',
    COUNT_BIG(*)
FROM core.NinosPT
WHERE UPPER(LTRIM(RTRIM(Diresa))) = 'LA LIBERTAD';
GO

--PARTE 2

USE BD_DataSalud;
GO

DELETE FROM dw.FactEvaluacionSalud;
GO


/* =========================
   GESTANTES
   ========================= */

INSERT INTO dw.FactEvaluacionSalud
(
    FechaKey,
    UbicacionKey,
    EstablecimientoKey,
    TipoEvaluacionKey,
    Edad,
    Sexo,
    Hemoglobina,
    Peso,
    Talla,
    PTZ,
    ZTE,
    ZPE,
    Diagnostico
)
SELECT
    F.FechaKey,
    U.UbicacionKey,
    E.EstablecimientoKey,
    T.TipoEvaluacionKey,
    G.Edad,
    NULL,
    G.Hemoglobina,
    G.Peso,
    G.Talla,
    NULL,
    NULL,
    NULL,
    G.Diagnostico
FROM core.Gestantes G

CROSS APPLY
(
    SELECT TOP 1 TipoEvaluacionKey
    FROM dw.DimTipoEvaluacion
    WHERE Codigo =
        CASE G.Fuente
            WHEN N'CLAP' THEN N'GEST_CLAP'
            WHEN N'IMC'  THEN N'GEST_IMC'
            ELSE N'GEST_IOM'
        END
) T

OUTER APPLY
(
    SELECT TOP 1 FechaKey
    FROM dw.DimFecha
    WHERE Fecha = G.AtencionFecha
    ORDER BY FechaKey
) F

OUTER APPLY
(
    SELECT TOP 1 UbicacionKey
    FROM dw.DimUbicacion
    WHERE ISNULL(Ubigeo,'') = ISNULL(G.Ubigeo,'')
      AND ISNULL(Diresa,'') = ISNULL(G.Diresa,'')
      AND ISNULL(Distrito,'') = ISNULL(G.Distrito,'')
    ORDER BY UbicacionKey
) U

OUTER APPLY
(
    SELECT TOP 1 EstablecimientoKey
    FROM dw.DimEstablecimiento
    WHERE ISNULL(Renipress,'') = ISNULL(G.Renipress,'')
      AND ISNULL(EESS,'') = ISNULL(G.EESS,'')
    ORDER BY EstablecimientoKey
) E;


/* =========================
   NIÑOS HB
   ========================= */

INSERT INTO dw.FactEvaluacionSalud
(
    FechaKey,
    UbicacionKey,
    EstablecimientoKey,
    TipoEvaluacionKey,
    Edad,
    Sexo,
    Hemoglobina,
    Peso,
    Talla,
    PTZ,
    ZTE,
    ZPE,
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
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    N.DxAnemia
FROM core.NinosHB N

CROSS APPLY
(
    SELECT TOP 1 TipoEvaluacionKey
    FROM dw.DimTipoEvaluacion
    WHERE Codigo = N'NINO_HB'
) T

OUTER APPLY
(
    SELECT TOP 1 FechaKey
    FROM dw.DimFecha
    WHERE Fecha = N.FechaAtencion
    ORDER BY FechaKey
) F

OUTER APPLY
(
    SELECT TOP 1 UbicacionKey
    FROM dw.DimUbicacion
    WHERE ISNULL(Ubigeo,'') = ISNULL(N.UbigeoPN,'')
      AND ISNULL(Diresa,'') = ISNULL(N.Diresa,'')
      AND ISNULL(Distrito,'') = ISNULL(N.DistritoPN,'')
    ORDER BY UbicacionKey
) U

OUTER APPLY
(
    SELECT TOP 1 EstablecimientoKey
    FROM dw.DimEstablecimiento
    WHERE ISNULL(Renipress,'') = ISNULL(N.Renipress,'')
      AND ISNULL(EESS,'') = ISNULL(N.EESS,'')
    ORDER BY EstablecimientoKey
) E;


/* =========================
   NIÑOS PESO/TALLA
   ========================= */

INSERT INTO dw.FactEvaluacionSalud
(
    FechaKey,
    UbicacionKey,
    EstablecimientoKey,
    TipoEvaluacionKey,
    Edad,
    Sexo,
    Hemoglobina,
    Peso,
    Talla,
    PTZ,
    ZTE,
    ZPE,
    Diagnostico
)
SELECT
    F.FechaKey,
    U.UbicacionKey,
    E.EstablecimientoKey,
    T.TipoEvaluacionKey,
    N.EdadMeses / 12.0,
    N.Sexo,
    NULL,
    N.Peso,
    N.Talla,
    N.PTZ,
    N.ZTE,
    N.ZPE,
    CONCAT(N.DxPT, N' | ', N.DxTE, N' | ', N.DxPE)
FROM core.NinosPT N

CROSS APPLY
(
    SELECT TOP 1 TipoEvaluacionKey
    FROM dw.DimTipoEvaluacion
    WHERE Codigo = N'NINO_PT'
) T

OUTER APPLY
(
    SELECT TOP 1 FechaKey
    FROM dw.DimFecha
    WHERE Fecha = N.FechaAtencion
    ORDER BY FechaKey
) F

OUTER APPLY
(
    SELECT TOP 1 UbicacionKey
    FROM dw.DimUbicacion
    WHERE ISNULL(Ubigeo,'') = ISNULL(N.UbigeoPN,'')
      AND ISNULL(Diresa,'') = ISNULL(N.Diresa,'')
      AND ISNULL(Distrito,'') = ISNULL(N.DistritoPN,'')
    ORDER BY UbicacionKey
) U

OUTER APPLY
(
    SELECT TOP 1 EstablecimientoKey
    FROM dw.DimEstablecimiento
    WHERE ISNULL(Renipress,'') = ISNULL(N.Renipress,'')
      AND ISNULL(EESS,'') = ISNULL(N.EESS,'')
    ORDER BY EstablecimientoKey
) E;
GO


/* =========================
   VALIDACIÓN
   ========================= */

SELECT COUNT_BIG(*) AS RegistrosDW
FROM dw.FactEvaluacionSalud;
GO