import csv
import json

ruta_csv = r"C:\Users\gameo\OneDrive\Desktop\db\db_proyecto\BD SIEN-HIS Niños 2024\BD SIEN-HIS Niños 2024\Hb\Niños LA LIBERTAD.csv"
ruta_json = r"C:\ninos_hb_la_libertad.json"

documentos = []

with open(ruta_csv, "r", encoding="utf-8-sig", newline="") as archivo:
    lector = csv.DictReader(archivo)

    for fila in lector:
        documento = {
            "origen": "SIEN-HIS 2024",
            "paciente": {
                "sexo": fila.get("Sexo"),
                "edad_meses": fila.get("EdadMeses"),
                "fecha_nacimiento": fila.get("FechaNacimiento")
            },
            "establecimiento": {
                "diresa": fila.get("Diresa"),
                "red": fila.get("Red"),
                "microred": fila.get("Microred"),
                "eess": fila.get("EESS"),
                "renipress": fila.get("Renipress")
            },
            "ubicacion": {
                "ubigeo": fila.get("UbigeoPN"),
                "departamento": fila.get("DepartamentoPN"),
                "provincia": fila.get("ProvinciaPN"),
                "distrito": fila.get("DistritoPN"),
                "centro_poblado": fila.get("CentroPobladoPN")
            },
            "hemoglobina": {
                "valor": fila.get("Hemoglobina"),
                "fecha": fila.get("FechaHemoglobina"),
                "diagnostico": fila.get("Dx_anemia")
            }
        }

        documentos.append(documento)

with open(ruta_json, "w", encoding="utf-8") as archivo:
    json.dump(
        documentos,
        archivo,
        ensure_ascii=False,
        indent=2
    )

print("Documentos generados:", len(documentos))
print("Archivo creado:", ruta_json)