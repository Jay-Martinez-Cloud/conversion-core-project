/* =========================================================
   Script: 04_Template_Permit_Load.sql
   Purpose:
     - Loads permits from source into target
     - Captures rejects into Permit_Rejects
   ========================================================= */

USE Client_Template_DB;
GO

/* ---------------------------------------------------------
   1) Reject rules (minimum viable)
   - Reject if PermitNo is NULL/blank
   - Reject if PermitType is NULL/blank
   - Reject if ApplicantName is NULL/blank
   --------------------------------------------------------- */
INSERT INTO dbo.Permit_Rejects (SourceKey, RejectReason, RejectDetail)
SELECT
    CAST(src.PermitNo AS NVARCHAR(100)) AS SourceKey,
    'Missing required field' AS RejectReason,
    CONCAT(
        'PermitNo=', COALESCE(NULLIF(LTRIM(RTRIM(src.PermitNo)), ''), '<NULL/BLANK>'),
        '; PermitType=', COALESCE(NULLIF(LTRIM(RTRIM(src.PermitType)), ''), '<NULL/BLANK>'),
        '; ApplicantName=', COALESCE(NULLIF(LTRIM(RTRIM(src.ApplicantName)), ''), '<NULL/BLANK>')
    ) AS RejectDetail
FROM Client_Source_DB.dbo.Legacy_Permits src
WHERE
    NULLIF(LTRIM(RTRIM(src.PermitNo)), '') IS NULL
    OR NULLIF(LTRIM(RTRIM(src.PermitType)), '') IS NULL
    OR NULLIF(LTRIM(RTRIM(src.ApplicantName)), '') IS NULL;
GO

/* ---------------------------------------------------------
   2) Load valid rows into Permit
   - Only load rows that pass required field rules
   - Prevent duplicates by PermitNumber (target field)
   --------------------------------------------------------- */
INSERT INTO dbo.Permit (PermitNumber, PermitType, ApplicantName)
SELECT
    LTRIM(RTRIM(src.PermitNo))        AS PermitNumber,
    LTRIM(RTRIM(src.PermitType))      AS PermitType,
    LTRIM(RTRIM(src.ApplicantName))   AS ApplicantName
FROM Client_Source_DB.dbo.Legacy_Permits src
WHERE
    NULLIF(LTRIM(RTRIM(src.PermitNo)), '') IS NOT NULL
    AND NULLIF(LTRIM(RTRIM(src.PermitType)), '') IS NOT NULL
    AND NULLIF(LTRIM(RTRIM(src.ApplicantName)), '') IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM dbo.Permit p
        WHERE p.PermitNumber = LTRIM(RTRIM(src.PermitNo))
    );
GO
