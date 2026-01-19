/* =========================================================
   01_CreateDBs.sql
   Purpose: Create Source + Template databases for Phase 3A
   Safe to re-run.
   ========================================================= */

USE master;
GO

IF DB_ID('EPL_Source_DB') IS NULL
BEGIN
    CREATE DATABASE EPL_Source_DB;
END
GO

IF DB_ID('EPL_Template_DB') IS NULL
BEGIN
    CREATE DATABASE EPL_Template_DB;
END
GO

-- Verify
SELECT name
FROM sys.databases
WHERE name IN ('EPL_Source_DB','EPL_Template_DB');
GO
