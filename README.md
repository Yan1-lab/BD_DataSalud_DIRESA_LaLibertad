# Sistema integrado de datos para la DIRESA La Libertad

Proyecto integrador del curso **Base de Datos Avanzadas y Big Data**.

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
│   ├── DataWarehouse_SQL.sql
│   ├── EVIDENCIA_DE_ROLES.sql
│   └── PROYECTO.sql
└── README.md
