/* =========================================================
   Script: 03_Template_Permit_Setup.sql
   Purpose:
     - Creates the target (Template) tables that represent
       your standardized schema + rejects table.

   Notes:
     - This is a SETUP script for local dev resets.
     - In production, you normally would NOT drop tables.
   ========================================================= */

USE Client_Template_DB;
GO

/* ---------------------------------------------------------
   Dev reset: Drop tables if they already exist
   --------------------------------------------------------- */
IF OBJECT_ID('dbo.Permit', 'U') IS NOT NULL
    DROP TABLE dbo.Permit;
GO

IF OBJECT_ID('dbo.Permit_Rejects', 'U') IS NOT NULL
    DROP TABLE dbo.Permit_Rejects;
GO

/* ---------------------------------------------------------
   Rejects table
   --------------------------------------------------------- */
CREATE TABLE dbo.Permit_Rejects (
    RejectId      INT IDENTITY(1,1) PRIMARY KEY,
    SourceKey     NVARCHAR(100) NULL,              -- optional "business key" from source
    RejectReason  NVARCHAR(200) NOT NULL,
    RejectDetail  NVARCHAR(4000) NULL,
    CreatedAt     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

/* ---------------------------------------------------------
   Target Permit table
   --------------------------------------------------------- */
CREATE TABLE dbo.Permit (
    PermitKey      INT IDENTITY(1,1) PRIMARY KEY,
    PermitNumber   VARCHAR(50)  NOT NULL,
    PermitType     VARCHAR(30)  NOT NULL,
    ApplicantName  VARCHAR(100) NOT NULL,
    LoadDtm        DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO
