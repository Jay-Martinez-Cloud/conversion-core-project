import csv
import json
from datetime import datetime
from pathlib import Path
import os

from .artifacts import upload_run_dir
from .db import (
    get_connection,
    execute_sql_file,
    fetch_scalar,
    fetch_from_sql_file,
)
from .reports import write_query_to_csv

print("🔥 run_conversion module loaded")


def list_sql_scripts(sql_dir: Path):
    return sorted([f for f in sql_dir.glob("[0-9][0-9]_*.sql")])


def ensure_run_dir(base_dir: Path):
    run_id = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    run_dir = base_dir / run_id
    run_dir.mkdir(parents=True, exist_ok=True)
    return run_id, run_dir


def write_step_results_csv(run_dir: Path, results: list[dict]):
    out = run_dir / "step_results.csv"
    fields = ["file", "status", "duration_ms",
              "rows_affected", "error", "path"]
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for r in results:
            w.writerow({k: r.get(k) for k in fields})


def write_run_summary_json(run_dir: Path, summary: dict):
    out = run_dir / "run_summary.json"
    with open(out, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)


def main():
    project_root = Path(__file__).resolve().parents[1]
    sql_dir = project_root / "sql"
    metrics_dir = sql_dir / "metrics"
    runs_base = project_root / "runs"

    run_id, run_dir = ensure_run_dir(runs_base)

    print(f"Run ID: {run_id}")
    print(f"Writing outputs to: {run_dir}")

    print("Connecting to SQL Server...")
    conn = get_connection(autocommit=False)
    print("✅ Connected")

    server_version = fetch_scalar(conn, "SELECT @@VERSION;")

    scripts = list_sql_scripts(sql_dir)

    print("\nScripts to run:")
    for s in scripts:
        print(" -", s.name)

    results = []
    any_fail = False

    # -------------------------
    # 1) Execute SQL scripts
    # -------------------------
    for script in scripts:
        print(f"\n▶ Running {script.name} ...")

        is_db_admin_step = script.name in {
            "01_CreateDBs.sql",
            "EPL_CreateDBs.sql",
        }

        if is_db_admin_step:
            print("   (using autocommit admin connection)")
            admin_conn = get_connection(autocommit=True)
            res = execute_sql_file(admin_conn, str(script))
            admin_conn.close()
        else:
            res = execute_sql_file(conn, str(script))

        results.append(res)

        if res["status"] == "success":
            print(f"✅ OK ({res['duration_ms']} ms)")
        else:
            any_fail = True
            print(f"❌ FAIL ({res['duration_ms']} ms)")
            print("   Error:", res["error"])
            break

    # -------------------------
    # 2) Write step results + summary
    # -------------------------
    summary = {
        "run_id": run_id,
        "status": "fail" if any_fail else "success",
        "server_version": server_version,
        "script_count": len(scripts),
        "scripts_ran": len(results),
        "outputs": {
            "step_results_csv": str(run_dir / "step_results.csv"),
            "run_summary_json": str(run_dir / "run_summary.json"),
            "row_counts_csv": str(run_dir / "row_counts.csv"),
            "reject_reason_summary_csv": str(run_dir / "reject_reason_summary.csv"),
        },
    }

    write_step_results_csv(run_dir, results)

    # -------------------------
    # 3) Post-run metrics (only if pipeline succeeded)
    # -------------------------
    if not any_fail:
        try:
            row_counts_sql = metrics_dir / "row_counts.sql"
            reject_summary_sql = metrics_dir / "reject_reason_summary.sql"

            if row_counts_sql.exists():
                cols, rows = fetch_from_sql_file(conn, str(row_counts_sql))
                write_query_to_csv(run_dir / "row_counts.csv", cols, rows)
                print("📊 Wrote row_counts.csv")

            if reject_summary_sql.exists():
                cols, rows = fetch_from_sql_file(conn, str(reject_summary_sql))
                write_query_to_csv(
                    run_dir / "reject_reason_summary.csv", cols, rows)
                print("📊 Wrote reject_reason_summary.csv")

        except Exception as e:
            print("⚠️ Metrics generation failed:", e)
    else:
        print("Skipping metrics because the pipeline failed before tables were created.")

    write_run_summary_json(run_dir, summary)

    conn.close()

    print("\nDone.")
    print("Summary:", summary["status"])
    print("Artifacts:")
    print(" -", summary["outputs"]["step_results_csv"])
    print(" -", summary["outputs"]["run_summary_json"])
    print(" -", summary["outputs"]["row_counts_csv"])
    print(" -", summary["outputs"]["reject_reason_summary_csv"])

    # -------------------------
    # 4) Upload artifacts to S3 (optional)
    # -------------------------
    bucket = os.getenv("ARTIFACTS_BUCKET")
    env = os.getenv("ENV", "dev")

    if bucket:
        try:
            uploaded = upload_run_dir(
                run_dir=run_dir,
                bucket=bucket,
                env=env,
                run_id=run_id
            )
            print(
                f"☁️ Uploaded {uploaded} artifacts to s3://{bucket}/runs/{env}/{run_id}/")
        except Exception as e:
            print(f"⚠️ S3 upload failed: {e}")
    else:
        print("☁️ ARTIFACTS_BUCKET not set; skipping S3 upload.")


if __name__ == "__main__":
    main()
