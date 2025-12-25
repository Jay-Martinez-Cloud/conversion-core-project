# Conversion Core Project (SQL Server + T-SQL)

All data, database names, and scenarios in this project are simulated for learning purposes.


This project simulates a real-world **data conversion** where legacy client data (Source_DB) is loaded into a fixed target schema (Template_DB) using **T-SQL** and **INSERT INTO ... SELECT** patterns.

It mirrors common Conversion Engineer workflows:
- Source data is messy and loosely constrained
- Template schema is standardized and strict
- Conversion logic handles basic data issues
- Load scripts are safe to re-run (idempotent)

---

## Tech Stack
- **SQL Server 2022** (running locally via Docker)
- **T-SQL** (conversion logic)
- **Azure Data Studio** (or VS Code) for query execution
- **Git + GitHub** (version control)

---

## Databases
- `Client_Source_DB`  
  Simulates client legacy data (messy by design).
- `Client_Template_DB`  
  Simulates your company’s target schema (fixed structure).

---

## Scripts and Run Order

Run these scripts **in order**:

1. **01_CreateDBs.sql**
   - Creates `Client_Source_DB` and `Client_Template_DB`
   - Drops them first if they already exist (local/dev reset)

2. **02_Source_Permits.sql**
   - Creates `dbo.Legacy_Permits` in `Client_Source_DB`
   - Inserts sample legacy data including bad data (NULL/blank PermitNo)

3. **03_Template_Permit_Setup.sql**
   - Creates `dbo.Permit` in `Client_Template_DB`
   - Setup-only script (run once per environment reset)

4. **04_Template_Permit_Load.sql**
   - Loads data from Source → Template using `INSERT INTO ... SELECT`
   - Handles missing PermitNo by generating:
     - `00-<ApplicantName>` (or `00-UNKNOWN`)
   - Uses `NOT EXISTS` to prevent double-loading on re-run
   - Includes validation queries (counts + data review)

---

## Docker SQL Server (Local Setup)

Start SQL Server in Docker:

```bash
docker run -d \
  --name sqlserver-dev \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=<your-strong-password>" \
  -p 1433:1433 \
  -v mssql_data:/var/opt/mssql \
  mcr.microsoft.com/mssql/server:2022-latest
