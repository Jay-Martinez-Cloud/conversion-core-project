from pathlib import Path
import os
import time
import pyodbc
from dotenv import load_dotenv

# ---------------------------------------------------------
# Load python/.env safely (never committed)
# ---------------------------------------------------------
load_dotenv(dotenv_path=Path(__file__).resolve().parent / ".env")


# ---------------------------------------------------------
# Database connection helper
# ---------------------------------------------------------
def get_connection(autocommit: bool = False):
    host = os.getenv("DB_HOST", "localhost")
    port = os.getenv("DB_PORT", "1433")
    user = os.getenv("DB_USER", "sa")
    password = os.getenv("DB_PASSWORD", "")
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")

    debug = os.getenv("DEBUG", "false").lower() == "true"
    if debug:
        print("DB_HOST:", host)
        print("DB_PORT:", port)
        print("DB_USER:", user)
        print("DB_PASSWORD set?:", bool(password))
        print("DB_DRIVER:", driver)

    if not password:
        raise ValueError(
            "DB_PASSWORD is empty. Check python/.env is present and loaded."
        )

    encrypt_flag = os.getenv("DB_ENCRYPT", "yes")
    trust_cert = os.getenv("DB_TRUST_CERT", "yes")

    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={host},{port};"
        f"UID={user};PWD={password};"
        f"Encrypt={encrypt_flag};"
        f"TrustServerCertificate={trust_cert};"
    )

    conn = pyodbc.connect(conn_str, timeout=10)
    conn.autocommit = autocommit
    return conn


# ---------------------------------------------------------
# SQL helpers
# ---------------------------------------------------------
def _split_sql_batches(sql_text: str):
    """
    Split SQL text on lines that contain only 'GO'
    (case-insensitive), like SSMS.
    """
    batches = []
    current = []

    for line in sql_text.splitlines():
        if line.strip().upper() == "GO":
            if current:
                batches.append("\n".join(current).strip())
                current = []
        else:
            current.append(line)

    if current:
        batches.append("\n".join(current).strip())

    return [b for b in batches if b]


def execute_sql_file(conn: pyodbc.Connection, file_path: str, timeout_s: int = 0):
    """
    Execute a .sql file as a single logical step.

    - Splits GO batches
    - Uses transaction when autocommit=False
    - Commits on success, rollbacks on error
    """
    start = time.time()
    cursor = conn.cursor()

    if timeout_s and timeout_s > 0:
        cursor.timeout = timeout_s

    sql_text = Path(file_path).read_text(encoding="utf-8")
    batches = _split_sql_batches(sql_text)

    total_rowcount = 0

    try:
        for batch in batches:
            cursor.execute(batch)
            if cursor.rowcount and cursor.rowcount > 0:
                total_rowcount += cursor.rowcount

        if not conn.autocommit:
            conn.commit()

        return {
            "file": Path(file_path).name,
            "path": str(file_path),
            "status": "success",
            "duration_ms": int((time.time() - start) * 1000),
            "rows_affected": total_rowcount,
            "error": None,
        }

    except Exception as e:
        if not conn.autocommit:
            conn.rollback()

        return {
            "file": Path(file_path).name,
            "path": str(file_path),
            "status": "fail",
            "duration_ms": int((time.time() - start) * 1000),
            "rows_affected": total_rowcount,
            "error": str(e),
        }

    finally:
        cursor.close()


# ---------------------------------------------------------
# Query helpers
# ---------------------------------------------------------
def fetch_scalar(conn: pyodbc.Connection, sql: str, params=None):
    cur = conn.cursor()
    try:
        cur.execute(sql, params or [])
        row = cur.fetchone()
        return row[0] if row else None
    finally:
        cur.close()


def fetch_all(conn: pyodbc.Connection, sql: str, params=None):
    cur = conn.cursor()
    try:
        cur.execute(sql, params or [])
        cols = [d[0] for d in cur.description] if cur.description else []
        rows = cur.fetchall()
        return cols, rows
    finally:
        cur.close()


def fetch_from_sql_file(conn: pyodbc.Connection, file_path: str, params=None):
    sql_text = Path(file_path).read_text(encoding="utf-8")
    return fetch_all(conn, sql_text, params=params)
