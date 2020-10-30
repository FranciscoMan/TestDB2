-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 07/06/2018
-- Description: get form saved by wo,form,id_production_line,idkform
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_FORMS_BY_WO_ALL] 		 
	 @PIN_ID_WORK_ORDER INT = NULL 
	,@PIN_ID_FORM INT = NULL 
	,@PIN_ID_PRODUCTION_LINE INT = NULL 
	,@PIN_ID_K_FORM INT = NULL 
AS
	SELECT  KY_FORM
		, NM_FORM
		, NO_FREQUENCE
		, NM_DATA_ACQUISITION_ORIGIN	
		, KY_STATUS_K_FORM
		, CASE WHEN NM_PROCESS = 'MANUFACTURE' THEN 'Extrusion' ELSE NM_PROCESS END AS NM_PROCESS
		, DT_FORM
		, DT_CLOSED
		, ID_BRANCH_PLANT
		, NO_WORK_ORDER
		, ID_K_FORM	
		, ID_FORM
		, ID_PALLET
		, NO_PALLET
		, NM_USER_AUTHORIZED_CANCEL
		, DS_EXPLANATION_CANCEL
FROM PRD.F_GET_FORMS_BY_WORK_ORDER(@PIN_ID_WORK_ORDER) KF
ORDER BY DT_FORM

