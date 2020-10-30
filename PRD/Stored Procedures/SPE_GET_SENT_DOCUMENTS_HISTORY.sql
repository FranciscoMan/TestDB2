﻿-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 07/07/2018
-- Description: get sent documents history
-- =============================================
-- Author: Gabriel Vázquez Torres
-- CREATE date: 23/07/2018
-- Description: Add the initial and end date parameters and change the document name filter condition
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_SENT_DOCUMENTS_HISTORY] 
	@PIN_ID_DOCUMENT_HISTORY AS INT = NULL
	, @PIN_ID_DOCUMENT AS UNIQUEIDENTIFIER = NULL
	, @PIN_NM_DOCUMENT AS NVARCHAR(300) = NULL
	, @PIN_KY_USER_SENDED AS NVARCHAR(50) = NULL
	, @PIN_DT_SENDED AS DATETIME = NULL
	, @PIN_DT_CONFIRM AS DATETIME = NULL
	, @PIN_ID_BRANCH_PLANT AS INT = NULL
	, @PIN_DT_CONFIRM_INIT AS DATETIME = NULL
	, @PIN_DT_CONFIRM_END AS DATETIME = NULL		
AS   

SELECT DH.ID_DOCUMENT_HISTORY
	, DH.ID_DOCUMENT
	, DH.NM_DOCUMENT
	, DH.KY_USER_SENDED
	, DH.NM_USER_SENDED
	, DH.DT_SENDED 
	, DH.DT_CONFIRM 
	, DH.ID_BRANCH_PLANT
	, BP.NM_BRANCH_PLANT
FROM PRD.K_DOCUMENT_HISTORY DH
	INNER JOIN ADM.C_BRANCH_PLANT BP 
		ON DH.ID_BRANCH_PLANT = BP.ID_BRANCH_PLANT
WHERE (@PIN_ID_BRANCH_PLANT IS NULL OR (@PIN_ID_BRANCH_PLANT IS NOT NULL AND DH.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))
	AND (@PIN_ID_DOCUMENT_HISTORY IS NULL OR (@PIN_ID_DOCUMENT_HISTORY IS NOT NULL AND DH.ID_DOCUMENT_HISTORY = @PIN_ID_DOCUMENT_HISTORY)) 
	AND (@PIN_ID_DOCUMENT IS NULL OR (@PIN_ID_DOCUMENT IS NOT NULL AND DH.ID_DOCUMENT = @PIN_ID_DOCUMENT))
	AND (@PIN_NM_DOCUMENT IS NULL OR (@PIN_NM_DOCUMENT IS NOT NULL AND DH.NM_DOCUMENT LIKE '%' + @PIN_NM_DOCUMENT + '%'))
	AND (@PIN_KY_USER_SENDED IS NULL OR (@PIN_KY_USER_SENDED IS NOT NULL AND DH.KY_USER_SENDED = @PIN_KY_USER_SENDED)) 
	AND (@PIN_DT_SENDED IS NULL OR (@PIN_DT_SENDED IS NOT NULL AND CAST(DH.DT_SENDED AS DATE) = CAST(@PIN_DT_SENDED AS DATE))) 
	AND (@PIN_DT_CONFIRM IS NULL OR (@PIN_DT_CONFIRM IS NOT NULL AND CAST(DH.DT_CONFIRM AS DATE) = CAST(@PIN_DT_CONFIRM AS DATE)))
	AND ((@PIN_DT_CONFIRM_INIT IS NULL AND @PIN_DT_CONFIRM_END IS NULL) OR ((@PIN_DT_CONFIRM_INIT IS NOT NULL AND @PIN_DT_CONFIRM_END IS NOT NULL) AND CAST(DH.DT_CONFIRM AS DATE) BETWEEN CAST(@PIN_DT_CONFIRM_INIT AS DATE) AND CAST(@PIN_DT_CONFIRM_END AS DATE)))
ORDER BY DH.DT_SENDED DESC

