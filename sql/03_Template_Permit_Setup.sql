/* =========================================================
   Script: 03_Template_Permit_Setup.sql
   Purpose:
     - Creates the target (Template) table that represents
       your company's standardized schema.

   This script represents:
     - A "company-owned" schema that is fixed and controlled
       by the product.
     - In real client projects, this table typically already
       exists (created by vendor tools / standard scripts).

   Notes:
     - This is a SETUP script (run once per environment reset).
     - Do NOT include this in a rerunnable conversion load step
       in production; dropping tables would destroy converted data.
   ========================================================= */

-- Switch context to the Template database
USE Client_Template_DB;
GO

/* ---------------------------------------------------------
   Drop the Permit table if it already exists
   This is included ONLY to support local development resets.
   It allows you to rerun setup scripts from a clean slate.
   --------------------------------------------------------- */
IF OBJECT_ID('dbo.Permit','U') IS NOT NULL
    DROP TABLE dbo.Permit;
GO

/* ---------------------------------------------------------
   Create the Permit table (target schema)
   Key design points:
     - PermitKey: surrogate primary key (identity)
       (common pattern in application databases)
     - PermitNumber: required field in the target system
     - LoadDtm: tracks when the record was inserted (audit)
   --------------------------------------------------------- */
CREATE TABLE dbo.Permit (
    PermitKey      INT IDENTITY(1,1) PRIMARY KEY,  -- internal unique row identifier
    PermitNumber   VARCHAR(50)  NOT NULL,           -- business identifier (must be present)
    PermitType     VARCHAR(30)  NOT NULL,           -- standardized category in target system
    ApplicantName  VARCHAR(100) NOT NULL,           -- required in target system
    LoadDtm        DATETIME2(0) NOT NULL DEFAULT SYSDATETIME() -- simple load audit timestamp
);
GO


--Optional: quick confirmation that the table exists
-- SELECT TOP 0 * FROM dbo.Permit;

