SELECT
  (SELECT COUNT(*) FROM Client_Source_DB.dbo.Legacy_Permits) AS SourceRowCount,
  (SELECT COUNT(*) FROM Client_Template_DB.dbo.Permit) AS PermitRowCount,
  (SELECT COUNT(*) FROM Client_Template_DB.dbo.Permit_Rejects) AS RejectRowCount;
