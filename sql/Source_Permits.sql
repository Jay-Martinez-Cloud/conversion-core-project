/* =========================================================
   02_Source_Permits.sql
   Purpose:
     - Create + seed legacy permit data in EPL_Source_DB
     - Includes intentionally bad data
   Safe to re-run.
   ========================================================= */

USE EPL_Source_DB;
GO

IF OBJECT_ID('dbo.Legacy_Permits','U') IS NOT NULL
    DROP TABLE dbo.Legacy_Permits;
GO

CREATE TABLE dbo.Legacy_Permits (
    LegacyPermitId  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PermitNo        VARCHAR(50)  NULL,   -- may be null/blank
    PermitType      VARCHAR(30)  NULL,   -- not standardized
    ApplicantName   VARCHAR(100) NULL    -- may be missing
);
GO

INSERT INTO dbo.Legacy_Permits (PermitNo, PermitType, ApplicantName)
VALUES
('BP-1001', 'Building',   'John Smith'),         -- valid
('BP-1002', 'Building',   'Jane Doe'),           -- valid
('EL-2001', 'Electrical', 'Acme LLC'),           -- valid
(NULL,      'Plumbing',   'Missing PermitNo'),   -- bad: null key
('  ',      'Fire',       'Blank PermitNo'),     -- bad: whitespace key
('BP-1001', 'Building',   'Duplicate PermitNo'); -- bad: duplicate permit number
GO

-- Validation
SELECT COUNT(*) AS SourceRowCount
FROM dbo.Legacy_Permits;

SELECT *
FROM dbo.Legacy_Permits
ORDER BY LegacyPermitId;
GO
