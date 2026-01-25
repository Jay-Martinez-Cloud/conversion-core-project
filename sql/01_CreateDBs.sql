/* =========================================================
   Script: 01_CreateDBs.sql
   Purpose:
     - Creates a clean, repeatable database environment
     - Sets up two databases used in the conversion project

   Databases:
     - Client_Source_DB   → simulates the client’s legacy system
     - Client_Template_DB → simulates the target application schema

   Notes:
     - LOCAL DEVELOPMENT ONLY
     - Safe to re-run: conditionally drops and recreates DBs
     - Uses SINGLE_USER + ROLLBACK IMMEDIATE to disconnect sessions
   ========================================================= */

-- Always start from the system database when creating/dropping databases
USE master;
GO

/* ---------------------------------------------------------
   Drop Source / Template databases if they already exist
   Force disconnect active sessions (dev reset only)
   --------------------------------------------------------- */

IF DB_ID('Client_Source_DB') IS NOT NULL
BEGIN
    ALTER DATABASE Client_Source_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Client_Source_DB;
END
GO

IF DB_ID('Client_Template_DB') IS NOT NULL
BEGIN
    ALTER DATABASE Client_Template_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Client_Template_DB;
END
GO

/* ---------------------------------------------------------
   Create the Source database
   --------------------------------------------------------- */
CREATE DATABASE Client_Source_DB;
GO

/* ---------------------------------------------------------
   Create the Template database
   --------------------------------------------------------- */
CREATE DATABASE Client_Template_DB;
GO

-- Optional: confirm databases were created
-- SELECT name
-- FROM sys.databases
-- WHERE name IN ('Client_Source_DB', 'Client_Template_DB');
