--Data Warehouse + ETL
USE BD_DataSalud;
GO

SELECT
    t.name AS Tabla,
    p.rows AS Registros
FROM sys.tables t
JOIN sys.schemas s
    ON s.schema_id = t.schema_id
JOIN sys.partitions p
    ON p.object_id = t.object_id
   AND p.index_id = 1
WHERE s.name = 'dw'
ORDER BY t.name;
GO

SELECT COUNT_BIG(*) AS TotalHechos
FROM dw.FactEvaluacionSalud;
GO

SELECT TOP 10 *
FROM dw.vw_KPIsSalud
ORDER BY Evaluaciones DESC;
GO

--CARGA ETL DW
USE BD_DataSalud;
GO

DELETE FROM dw.FactNinosHB_ETL;
GO

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

CROSS JOIN
(
    SELECT TOP 1 TipoEvaluacionKey
    FROM dw.DimTipoEvaluacion
    WHERE Codigo = N'NINO_HB'
) T

OUTER APPLY
(
    SELECT TOP 1
        D.FechaKey
    FROM dw.DimFecha D
    WHERE D.Fecha = N.FechaAtencion
    ORDER BY D.FechaKey
) F

OUTER APPLY
(
    SELECT TOP 1
        D.UbicacionKey
    FROM dw.DimUbicacion D
    WHERE ISNULL(D.Ubigeo, '') = ISNULL(N.UbigeoPN, '')
      AND ISNULL(D.Diresa, '') = ISNULL(N.Diresa, '')
      AND ISNULL(D.Distrito, '') = ISNULL(N.DistritoPN, '')
    ORDER BY D.UbicacionKey
) U

OUTER APPLY
(
    SELECT TOP 1
        D.EstablecimientoKey
    FROM dw.DimEstablecimiento D
    WHERE ISNULL(D.Renipress, '') = ISNULL(N.Renipress, '')
      AND ISNULL(D.EESS, '') = ISNULL(N.EESS, '')
    ORDER BY D.EstablecimientoKey
) E;
GO

SELECT COUNT_BIG(*) AS FilasEnDW
FROM dw.FactNinosHB_ETL;
GO

--TABLAS ETL

USE BD_DataSalud;
GO

IF OBJECT_ID(N'etl.NinosHB_Python', N'U') IS NULL
BEGIN
    CREATE TABLE etl.NinosHB_Python
    (
        IdETL BIGINT IDENTITY(1,1) PRIMARY KEY,
        Diresa NVARCHAR(150),
        EESS NVARCHAR(500),
        Renipress NVARCHAR(50),
        Sexo NVARCHAR(20),
        FechaAtencion DATE,
        FechaNacimiento DATE,
        EdadMeses DECIMAL(10,2),
        UbigeoPN CHAR(6),
        DepartamentoPN NVARCHAR(150),
        ProvinciaPN NVARCHAR(150),
        DistritoPN NVARCHAR(150),
        CentroPobladoPN NVARCHAR(250),
        Hemoglobina DECIMAL(8,2),
        FechaHemoglobina DATE,
        DxAnemia NVARCHAR(100),
        FechaETL DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID(N'dw.FactNinosHB_ETL', N'U') IS NULL
BEGIN
    CREATE TABLE dw.FactNinosHB_ETL
    (
        ETLFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,
        FechaKey INT NULL,
        UbicacionKey INT NULL,
        EstablecimientoKey INT NULL,
        TipoEvaluacionKey INT NOT NULL,
        Edad DECIMAL(10,2) NULL,
        Sexo NVARCHAR(20) NULL,
        Hemoglobina DECIMAL(8,2) NULL,
        Diagnostico NVARCHAR(100) NULL,
        FechaCarga DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

SELECT
    s.name AS Esquema,
    t.name AS Tabla
FROM sys.tables t
JOIN sys.schemas s
    ON s.schema_id = t.schema_id
WHERE
    (s.name = N'etl' AND t.name = N'NinosHB_Python')
    OR
    (s.name = N'dw' AND t.name = N'FactNinosHB_ETL');
GO

--COMPROBACIÓN DEL LOG
USE BD_DataSalud;
GO

SELECT TOP 10
    IdLogETL,
    FechaInicio,
    FechaFin,
    Proceso,
    FilasExtraidas,
    FilasTransformadas,
    FilasCargadas,
    Estado,
    Mensaje
FROM etl.LogEjecucion
ORDER BY IdLogETL DESC;
GO

SELECT COUNT_BIG(*) AS RegistrosETL
FROM etl.NinosHB_Python;
GO

SELECT COUNT_BIG(*) AS RegistrosDW
FROM dw.FactNinosHB_ETL;
GO

--RENDIMIENTO:
USE BD_DataSalud;
GO

-- ANTES DEL INDICE
DROP INDEX IF EXISTS IX_NinosHB_UbigeoPN
ON core.NinosHB;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT 
    Diresa,
    DistritoPN,
    COUNT_BIG(*) AS Registros,
    AVG(Hemoglobina) AS PromedioHb
FROM core.NinosHB
WHERE UbigeoPN = '130101'
GROUP BY Diresa, DistritoPN;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- CREAR INDICE
CREATE INDEX IX_NinosHB_UbigeoPN
ON core.NinosHB (UbigeoPN)
INCLUDE (Diresa, DistritoPN, Hemoglobina);
GO

-- DESPUES DEL INDICE
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT 
    Diresa,
    DistritoPN,
    COUNT_BIG(*) AS Registros,
    AVG(Hemoglobina) AS PromedioHb
FROM core.NinosHB
WHERE UbigeoPN = '130101'
GROUP BY Diresa, DistritoPN;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO