import csv
from pathlib import Path


def write_query_to_csv(csv_path: Path, columns: list[str], rows):
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(columns)
        for r in rows:
            w.writerow(list(r))
