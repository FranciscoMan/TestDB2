-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 2017/06/07
-- Description: Get notification for view
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_NOTIFICATION_VIEW]
	@PIN_KY_PROCESS NVARCHAR(50)
AS   
BEGIN				

	SELECT
		 KY_PROCESS
		--,CP.KY_TELEGRAM
		--,CP.KY_EMAIL
		--,CU.KY_USER
		,NM_FORM
		,DS_BODY
		,DS_TITLE
		,DS_SUBJECT
		,NM_URL
		,NM_URL_PARAMETERS
		,PN.NO_WIDTH
		,NO_HEIGHT
		,FG_EMAIL
		,FG_TELEGRAM
		,FG_ALERT
		,FG_FORM
	FROM PRD.VW_C_PROCESS_NOTIFICATION PN
	WHERE PN.KY_PROCESS = @PIN_KY_PROCESS
END

