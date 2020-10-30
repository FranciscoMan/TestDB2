-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Gabriel Vázquez Torres
-- CREATE date: 2017/06/07
-- Description: Get notification for MRB
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_MRB_RESOLUTION_NOTIFICATION]
	@PIN_ID_WORK_ORDER AS int, 
	@PIN_ID_PALLET INT,
	@PIN_ID_BRANCH_PLANT INT,
	@PIN_KY_PROCESS NVARCHAR(50)
AS   
BEGIN			

SELECT
		 KY_PROCESS
		,'' KY_TELEGRAM--,CP.KY_TELEGRAM
		,'' KY_EMAIL--,CP.KY_EMAIL
		,'' KY_USER --CU.KY_USER
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
	FROM PRD.K_INSPECTION_SKID KP 
		, PRD.VW_C_PROCESS_NOTIFICATION  PN
	WHERE PN.KY_PROCESS = @PIN_KY_PROCESS
		AND KP.ID_INSPECTION_SKID = @PIN_ID_PALLET

END

