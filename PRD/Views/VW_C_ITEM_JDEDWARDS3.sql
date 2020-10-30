﻿




CREATE VIEW [PRD].[VW_C_ITEM_JDEDWARDS3] AS (
	SELECT CONVERT(INT, COALESCE(I.IMITM, 0)) AS ID_ITEM
		, COALESCE(I.IMLITM, '') AS KY_ITEM
		, LTRIM(RTRIM(COALESCE(I.IMDSC1, ''))) + ' ' + LTRIM(RTRIM(COALESCE(I.IMDSC2, ''))) AS NM_ITEM
		, LTRIM(RTRIM(COALESCE(I.IMDSC1, ''))) + ' ' + LTRIM(RTRIM(COALESCE(I.IMDSC2, ''))) AS DS_ITEM
		, COALESCE(I.IMUPCN, '') AS KY_UPC
		, CONVERT(DECIMAL(20,10), (M.UMCONV / 10000000)) AS NO_POUNDS_PER_ITEM
		, CONVERT(INT, (SQ.UMCONV / 10000000)) AS NO_SKID_QTY
		, '' AS DS_NOTES_JDEDWARDS
	FROM    OPENQUERY(JDEPROD ,'SELECT * FROM PRODDTA.F4101' ) AS I LEFT OUTER JOIN
                OPENQUERY(JDEPROD ,'SELECT * FROM PRODDTA.F41002' ) AS M ON I.IMITM = M.UMITM AND M.UMUM = 'EA' AND M.UMRUM = 'NW' LEFT OUTER JOIN
                    OPENQUERY(JDEPROD ,'SELECT * FROM PRODDTA.F41002' ) AS SQ ON I.IMITM = SQ.UMITM AND SQ.UMUM = 'PL' AND SQ.UMRUM IN ('CT', 'EA')
)
