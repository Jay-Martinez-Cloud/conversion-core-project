/* =========================================================
   Script: 04_Template_Permit_Load.sql
   Purpose:
     - Loads data from the client Source database into the
       company Template database using INSERT INTO ... SELECT.
     - Handles basic bad data (missing/blank PermitNo) by
       generating a deterministic PermitNumber.
     - Is safe to re-run (idempotent) using NOT EXISTS.

   Source:
     Client_Source_DB.dbo.Legacy_Permits

   Target:
     Client_Template_DB.dbo.Permit

   Notes:
     - This script performs DML only (INSERT).
     - No schema changes are made here (mirrors real work).
     - Rerun safety prevents accidental double-loading.
   ========================================================= */

-- Switch context to the Template database (target)
USE Client_Template_DB;
GO

/* ---------------------------------------------------------
   Insert converted records into the Template table

   Key behaviors:
     1) Trim whitespace (LTRIM/RTRIM) to handle messy legacy text
     2) If PermitNo is NULL/blank, generate a PermitNumber:
          '00-' + ApplicantName (or 'UNKNOWN' if name is missing)
     3) Default PermitType / ApplicantName if NULL
     4) Prevent duplicate inserts using NOT EXISTS:
          - If a PermitNumber already exists in dbo.Permit,
            we skip inserting it again
   --------------------------------------------------------- */
INSERT INTO dbo.Permit
(
  PermitNumber,
  PermitType,
  ApplicantName
)
SELECT
  x.PermitNumber,
  x.PermitType,
  x.ApplicantName
FROM (
    SELECT
      CASE
        -- If PermitNo is NULL or whitespace, generate a stable value
        WHEN NULLIF(LTRIM(RTRIM(s.PermitNo)), '') IS NULL
          THEN CONCAT(
                 '00-',
                 ISNULL(NULLIF(LTRIM(RTRIM(s.ApplicantName)), ''), 'UNKNOWN')
               )

        -- Otherwise, use the trimmed PermitNo
        ELSE LTRIM(RTRIM(s.PermitNo))
      END AS PermitNumber,

      -- Default PermitType if missing (simple standardization)
      ISNULL(s.PermitType, 'Other')      AS PermitType,

      -- Default ApplicantName if missing
      ISNULL(s.ApplicantName, 'Unknown') AS ApplicantName

    FROM Client_Source_DB.dbo.Legacy_Permits s
) x
WHERE NOT EXISTS (
    -- Rerun safety: do not insert a PermitNumber that already exists
    SELECT 1
    FROM dbo.Permit t
    WHERE t.PermitNumber = x.PermitNumber
);
GO

/* ---------------------------------------------------------
   Validation queries
   These help confirm the conversion results quickly.
   --------------------------------------------------------- */

-- Row counts: Source vs Template
SELECT COUNT(*) AS SourceRowCount
FROM Client_Source_DB.dbo.Legacy_Permits;

SELECT COUNT(*) AS TemplateRowCount
FROM dbo.Permit;

-- View loaded data
SELECT *
FROM dbo.Permit
ORDER BY PermitKey;

-- Show rows where a PermitNumber was generated (missing/blank PermitNo)
SELECT *
FROM dbo.Permit
WHERE PermitNumber LIKE '00-%'
ORDER BY PermitKey;
GO
