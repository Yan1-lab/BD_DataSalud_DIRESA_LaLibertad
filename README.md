# Sistema integrado de datos para la DIRESA La Libertad

Proyecto integrador del curso **Base de Datos Avanzadas y Big Data - CIIN1021P**.

## Objetivo

Diseñar e implementar un sistema integrado de datos para apoyar el análisis de información de salud de la DIRESA La Libertad, utilizando SQL Server, MongoDB, Power BI, Python y Apache Spark.

## Alcance

El proyecto utiliza conjuntos de datos SIEN-HIS 2024 relacionados con:

- Gestantes CLAP
- Gestantes IMC
- Gestantes IOM
- Niños Hb
- Niños Peso/Talla
- UBIGEO RENIEC

El análisis principal se concentra en la **DIRESA La Libertad**.

## Tecnologías utilizadas

- SQL Server Management Studio 22
- MongoDB Community Server / MongoDB Compass
- Python
- Power BI Desktop
- Apache Spark / PySpark
- Git y GitHub

## Estructura del repositorio

```text
BD_DataSalud/
├── ETL/
│   └── etl_ninos_hb.py
├── MongoDB/
│   └── cargar_mongodb.py
├── PowerBI/
│   └── Dashboard_DIRESA_LaLibertad.pbix
├── Spark/
│   └── Spark_DIRESA_LaLibertad.ipynb
├── SQL/
│   ├── PROYECTO.sql
│   ├── DataWarehouse_SQL.sql
│   ├── EVIDENCIA_DE_ROLES.sql
│   ├── BACKUP_RESTORE.sql
│   └── CORRECCION_DW_FACT.sql
└── README.md
```

## Componentes principales

### SQL Server

Implementación de:

- Tablas de staging y core
- Procedimientos almacenados
- Triggers de auditoría e integridad
- Función de normalización de UBIGEO
- Roles y permisos
- Auditoría
- Backup y restore
- Índices y análisis de rendimiento
- Data Warehouse dimensional

### MongoDB

Se implementó la colección `ninos_hb` con datos de Niños Hb de La Libertad. Se importaron **81,052 documentos** y se validaron operaciones CRUD.

### ETL

El proceso ETL en Python realiza extracción, transformación, limpieza, normalización de UBIGEO, conversión de fechas y valores numéricos, eliminación de filas completamente vacías, deduplicación, carga al Data Warehouse y registro de la ejecución.

Ejecución validada:

- Filas extraídas: **81,052**
- Filas transformadas: **80,894**
- Filas cargadas: **80,894**
- Filas en DW específico: **80,894**

### Data Warehouse

El modelo dimensional utiliza una tabla de hechos `dw.FactEvaluacionSalud` y dimensiones de fecha, ubicación, establecimiento y tipo de evaluación.

Control final de consistencia:

- CORE Gestantes: **65,867**
- CORE Niños Hb: **81,052**
- CORE Niños PT: **116,209**
- FactEvaluacionSalud: **263,128**
- Registros de la DIRESA La Libertad: **263,128**

### Power BI

El dashboard presenta:

- Total de evaluaciones: **263 mil**
- Promedio de hemoglobina: **12.39**
- Casos de anemia: **9 mil**
- Filtro `Diresa = LA LIBERTAD`
- Análisis geográfico por provincia y distrito
- Drill-down Provincia → Distrito

### Apache Spark

El notebook PySpark utiliza:

- Spark DataFrame
- SparkSQL
- Agregaciones y estadísticas descriptivas
- Comparación de rendimiento frente a SQL Server

Resultado de la prueba de rendimiento:

- SQL Server: **24 ms**
- Spark: **1,345.5 ms**

En el escenario probado con 81,052 registros, Spark tardó aproximadamente **56.1 veces** el tiempo de la consulta de SQL Server.

## Backup y restore

El proyecto incluye `BACKUP_RESTORE.sql`, con verificación del backup y restauración de prueba sobre `BD_DataSalud_RestorePrueba`.

## Corrección del Data Warehouse

El proyecto incluye `CORRECCION_DW_FACT.sql`, utilizado para evitar la multiplicación de registros durante los JOIN con las dimensiones y garantizar la correspondencia uno a uno entre los registros de CORE y el hecho final.

## Ejecución

1. Crear y configurar la base de datos SQL Server.
2. Cargar y perfilar los datos.
3. Ejecutar los objetos de automatización y seguridad.
4. Implementar el Data Warehouse.
5. Ejecutar el proceso ETL.
6. Abrir el dashboard de Power BI.
7. Ejecutar el notebook de Spark.
8. Revisar MongoDB y las operaciones CRUD.

## Repositorio

https://github.com/Yan1-lab/BD_DataSalud_DIRESA_LaLibertad

## Consideraciones

Los archivos de datos fuente originales no se incluyen en este repositorio debido a su tamaño. Se mantienen localmente para conservar el repositorio enfocado en código, procesamiento, resultados y trazabilidad.
