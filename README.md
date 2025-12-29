# Conversion Core Project (SQL Server + T-SQL)

This project is for **educational and demonstration purposes only**.  
No real client data, schemas, or proprietary logic are used.

---

## Phase 1 – Core Conversion (T-SQL)

This project simulates a real-world **data conversion** where legacy client data is loaded into a fixed target schema using **T-SQL** and `INSERT INTO ... SELECT` patterns.

It mirrors common Conversion Engineer workflows:
- Source data is messy and loosely constrained
- Template schema is standardized and strict
- Conversion logic handles basic data issues
- Load scripts are safe to re-run (idempotent)

---

## Tech Stack
- **SQL Server 2022**
- **T-SQL**
- **Docker**
- **Azure Data Studio** (or VS Code)
- **Git & GitHub**

---

## Databases
- `Client_Source_DB`  
  Simulates client legacy data (messy by design).

- `Client_Template_DB`  
  Simulates a company-owned target schema with strict requirements.

---

## Scripts and Run Order

Run these scripts **in order**:

1. **01_CreateDBs.sql**
   - Creates `Client_Source_DB` and `Client_Template_DB`
   - Drops existing databases first to allow clean local resets

2. **02_Source_Permits.sql**
   - Creates `dbo.Legacy_Permits` in `Client_Source_DB`
   - Inserts sample legacy data including bad data (NULL and blank PermitNo)

3. **03_Template_Permit_Setup.sql**
   - Creates `dbo.Permit` in `Client_Template_DB`
   - Setup-only script (run once per environment reset)

4. **04_Template_Permit_Load.sql**
   - Loads data from Source → Template using `INSERT INTO ... SELECT`
   - Handles missing PermitNo by generating:
     - `00-<ApplicantName>` or `00-UNKNOWN`
   - Designed to be safely re-run
   - Includes validation queries (row counts and data review)

---

## Docker SQL Server (Local Environment)

SQL Server runs locally in Docker to provide an isolated development environment that does not depend on a host-installed database engine.

The environment is intentionally disposable and can be recreated at any time using the provided scripts.

---

## Phase 2 – Docker Compose

The SQL Server environment is defined using **Docker Compose**, replacing the one-off `docker run` approach used during initial setup.

Docker Compose provides a **declarative and reproducible** environment definition.

Start SQL Server
```bash
docker compose up -d
```

StopSQL Server
```bash
docker compose down
```




