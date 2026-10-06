--CARPETA DONDE ESTAN LOS BACKUP, DATOS Y LOG

USE master;
GO

SELECT 
    CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultBackupPath')) AS CarpetaBackup,
    CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultDataPath')) AS CarpetaDatos,
    CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultLogPath')) AS CarpetaLog;


--COMPROBACIÓN

USE master;
GO

DECLARE @BackupFile NVARCHAR(4000);

SET @BackupFile =
    CONVERT(NVARCHAR(4000), SERVERPROPERTY('InstanceDefaultBackupPath'));

IF RIGHT(@BackupFile,1) NOT IN ('\','/')
    SET @BackupFile += N'\';

SET @BackupFile += N'BD_DataSalud_FULL.bak';

SELECT @BackupFile AS ArchivoBackup;

EXEC master.dbo.xp_fileexist @BackupFile;
GO


--RESTORE PRUEBA

USE master;
GO

DECLARE @BackupFile NVARCHAR(4000);
DECLARE @BackupSetID INT;
DECLARE @DataPath NVARCHAR(4000);
DECLARE @LogPath NVARCHAR(4000);
DECLARE @Moves NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

-- Ruta del backup
SET @BackupFile = CONVERT(NVARCHAR(4000),
    SERVERPROPERTY('InstanceDefaultBackupPath'));

IF RIGHT(@BackupFile, 1) NOT IN ('\', '/')
    SET @BackupFile += N'\';

SET @BackupFile += N'BD_DataSalud_FULL.bak';

-- Verificar backup
RESTORE VERIFYONLY FROM DISK = @BackupFile;

-- Buscar el último backup FULL registrado
SELECT TOP 1
    @BackupSetID = backup_set_id
FROM msdb.dbo.backupset
WHERE database_name = N'BD_DataSalud'
  AND type = 'D'
ORDER BY backup_finish_date DESC;

-- Rutas de destino
SET @DataPath = CONVERT(NVARCHAR(4000),
    SERVERPROPERTY('InstanceDefaultDataPath'));

SET @LogPath = CONVERT(NVARCHAR(4000),
    SERVERPROPERTY('InstanceDefaultLogPath'));

IF RIGHT(@DataPath, 1) NOT IN ('\', '/')
    SET @DataPath += N'\';

IF RIGHT(@LogPath, 1) NOT IN ('\', '/')
    SET @LogPath += N'\';

-- Construir MOVE para los archivos
SELECT @Moves =
    STRING_AGG(
        N'MOVE N''' +
        REPLACE(logical_name, '''', '''''') +
        N''' TO N''' +
        REPLACE(
            CASE 
                WHEN file_type = 'L' THEN
                    @LogPath + N'RestorePrueba_' +
                    RIGHT(physical_name,
                          CHARINDEX(N'\', REVERSE(physical_name)) - 1)
                ELSE
                    @DataPath + N'RestorePrueba_' +
                    RIGHT(physical_name,
                          CHARINDEX(N'\', REVERSE(physical_name)) - 1)
            END,
            '''', ''''''
        ) +
        N'''',
        N','
    )
FROM msdb.dbo.backupfile
WHERE backup_set_id = @BackupSetID;

-- Eliminar restauración anterior si existiera
IF DB_ID(N'BD_DataSalud_RestorePrueba') IS NOT NULL
BEGIN
    ALTER DATABASE BD_DataSalud_RestorePrueba
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE BD_DataSalud_RestorePrueba;
END;

-- Restaurar
SET @SQL =
    N'RESTORE DATABASE BD_DataSalud_RestorePrueba
      FROM DISK = N''' +
    REPLACE(@BackupFile, '''', '''''') +
    N''' WITH ' + @Moves + N', RECOVERY, STATS = 10;';

EXEC sys.sp_executesql @SQL;
GO

-- Verificar resultado
SELECT
    name AS BaseDatos,
    state_desc AS Estado
FROM sys.databases
WHERE name = N'BD_DataSalud_RestorePrueba';
GO