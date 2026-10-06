--EVIDENCIA DE LOS 3 ROLES

USE BD_DataSalud;
GO

SELECT
    dp.name AS Rol,
    dp.type_desc AS TipoRol
FROM sys.database_principals dp
WHERE dp.name IN
(
    'rol_DataSalud_Admin',
    'rol_DataSalud_Analista',
    'rol_DataSalud_Auditor'
)
ORDER BY dp.name;
GO

SELECT
    RoleName = r.name,
    PermissionName = p.permission_name,
    PermissionState = p.state_desc,
    ObjectName = OBJECT_SCHEMA_NAME(p.major_id) + '.' + OBJECT_NAME(p.major_id)
FROM sys.database_principals r
JOIN sys.database_permissions p
    ON p.grantee_principal_id = r.principal_id
WHERE r.name IN
(
    'rol_DataSalud_Admin',
    'rol_DataSalud_Analista',
    'rol_DataSalud_Auditor'
)
ORDER BY r.name, ObjectName;
GO