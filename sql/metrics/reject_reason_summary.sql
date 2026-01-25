SELECT RejectReason, COUNT(*) AS CT
FROM Client_Template_DB.dbo.Permit_Rejects
GROUP BY RejectReason
ORDER BY CT DESC;
