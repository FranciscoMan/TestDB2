-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Gabriel Vázquez Torres
-- CREATE date: 24/05/2018
-- Description: get all the position related to a problem code to send notification of closed lost time event
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_POSITION_BY_PROBLEM_CODE] 
	@PIN_ID_PROBLEM_CODE AS INT,
	@PIN_ID_BRANCH_PLANT AS INT
AS

	SELECT 
		CPA.ID_POSITION_CODE, 
		CPA.ID_PROBLEM_CODE, 
		CPA.ID_POSITION, 
		CP.KY_POSITION, 
		CP.NM_POSITION,
		CP.KY_EMAIL
	FROM PRD.C_CODES_POSITION_ALERT CPA
		INNER JOIN ADM.C_POSITION CP ON CP.ID_POSITION = CPA.ID_POSITION
	WHERE 
		(@PIN_ID_PROBLEM_CODE IS NULL OR(@PIN_ID_PROBLEM_CODE IS NOT NULL AND CPA.ID_PROBLEM_CODE = @PIN_ID_PROBLEM_CODE)) AND 
		(@PIN_ID_BRANCH_PLANT IS NULL OR(@PIN_ID_BRANCH_PLANT IS NOT NULL AND CP.ID_BRANCH_PLANT = @PIN_ID_BRANCH_PLANT))

