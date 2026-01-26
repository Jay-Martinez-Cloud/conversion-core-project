from pathlib import Path
import boto3


def upload_run_dir(run_dir: str | Path, bucket: str, env: str, run_id: str) -> int:
    """
    Uploads all files under runs/<run_id>/ to:
      s3://<bucket>/runs/<env>/<run_id>/
    """
    run_path = Path(run_dir).resolve()
    if not run_path.exists():
        raise FileNotFoundError(f"Run directory not found: {run_path}")

    prefix = f"runs/{env}/{run_id}"
    s3 = boto3.client("s3")

    uploaded = 0
    for file_path in run_path.rglob("*"):
        if file_path.is_file():
            key = f"{prefix}/{file_path.relative_to(run_path)}"
            s3.upload_file(str(file_path), bucket, key)
            uploaded += 1

    return uploaded
