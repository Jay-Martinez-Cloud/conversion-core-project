/* =========================================================
   Script: 02_Source_Permits.sql
   Purpose:
     - Simulates a client's legacy permitting data
     - Intentionally includes bad / messy data to reflect
       real-world conversion scenarios

   This script represents:
     - A Source database that the conversion engineer
       DOES NOT control
     - Data quality issues that must be handled during
       the conversion into the Template database

   Notes:
     - This script is safe to re-run in a sandbox
     - In real projects, this data would come from a
       restored client backup, not be manually created
   ========================================================= */

-- Switch context to the Source database
USE Client_Source_DB;
GO

/* ---------------------------------------------------------
   Drop the legacy table if it already exists
   This allows the script to be re-run during development
   without manual cleanup.
   --------------------------------------------------------- */
IF OBJECT_ID('dbo.Legacy_Permits','U') IS NOT NULL
    DROP TABLE dbo.Legacy_Permits;
GO

/* ---------------------------------------------------------
   Create the legacy permits table
   This schema is intentionally simple and loosely defined
   to simulate a legacy system with minimal constraints.
   --------------------------------------------------------- */
CREATE TABLE dbo.Legacy_Permits (
    PermitNo        VARCHAR(50)  NULL,   -- May be NULL or blank in legacy data
    PermitType      VARCHAR(30)  NULL,   -- Not always standardized
    ApplicantName   VARCHAR(100) NULL    -- May be missing or inconsistent
);
GO

/* ---------------------------------------------------------
   Insert sample legacy data
   This data intentionally includes:
     - Valid records
     - NULL permit numbers
     - Blank permit numbers
   These issues will be addressed during conversion.
   --------------------------------------------------------- */
INSERT INTO dbo.Legacy_Permits
(
  PermitNo,
  PermitType,
  ApplicantName
)
VALUES
('BP-1001', 'Building',   'John Smith'),        -- valid record
('BP-1002', 'Building',   'Jane Doe'),          -- valid record
('EL-2001', 'Electrical', 'Acme LLC'),           -- valid record
(NULL,      'Plumbing',   'Missing PermitNo'),  -- bad data: NULL key
('  ',      'Fire',       'Blank PermitNo');    -- bad data: whitespace key
GO

/* ---------------------------------------------------------
   Validation queries
   Used to confirm that the legacy data loaded as expected
   --------------------------------------------------------- */
SELECT COUNT(*) AS SourceRowCount
FROM dbo.Legacy_Permits;

SELECT *
FROM dbo.Legacy_Permits;
GO
