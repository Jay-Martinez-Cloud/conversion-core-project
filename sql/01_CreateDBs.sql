/* =========================================================
   Script: 01_CreateDBs.sql
   Purpose:
     - Creates a clean, repeatable database environment
     - Sets up two databases used in the conversion project

   Databases:
     - Client_Source_DB   → simulates the client’s legacy system
     - Client_Template_DB → simulates the target application schema

   Notes:
     - This script is intended for LOCAL DEVELOPMENT ONLY
     - It is safe to re-run because it conditionally drops databases
     - In real client projects, databases already exist and
       this script would typically NOT be run by the conversion engineer
   ========================================================= */

-- Always start from the system database when creating/dropping databases
USE master;
GO

/* ---------------------------------------------------------
   Drop Source database if it already exists
   This ensures a clean slate so the script can be re-run
   without manual cleanup. This is for repeatability in a sandbox environment.
   --------------------------------------------------------- */
IF DB_ID('Client_Source_DB') IS NOT NULL
    DROP DATABASE Client_Source_DB;

IF DB_ID('Client_Template_DB') IS NOT NULL
    DROP DATABASE Client_Template_DB;
GO

/* ---------------------------------------------------------
   Create the Source database
   This database represents the client's legacy system
   --------------------------------------------------------- */
CREATE DATABASE Client_Source_DB;

/* ---------------------------------------------------------
   Create the Template database
   This database represents the target application schema
   --------------------------------------------------------- */
CREATE DATABASE Client_Template_DB;
GO

--Uncomment if you want to confirm databases were created
-- SELECT name
-- FROM sys.databases
-- WHERE name IN ('Client_Source_DB', 'Client_Template_DB');
