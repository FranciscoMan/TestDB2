-- =============================================
-- Proyecto: Plaskolite
-- Author: Daniel Dávalos Romero
-- CREATE date: 24/06/2020
-- Description: Get assigned functions from specific user
-- =============================================
CREATE PROCEDURE  [ADM].[SPE_GET_FUNCTIONS_BY_USER]
	@PIN_KY_USER AS NVARCHAR(100)
AS   
BEGIN
	-- Getting Position from KY_USER
	DECLARE @V_ID_POSITION INT = 
	(
		SELECT TOP 1 pos.ID_POSITION 
		FROM ADM.C_USER us
		INNER JOIN ADM.C_EMPLOYEE em ON us.ID_EMPLOYEE = em.ID_EMPLOYEE
		INNER JOIN ADM.C_POSITION pos ON em.ID_POSITION = pos.ID_POSITION
		WHERE us.KY_USER = @PIN_KY_USER
	)

	-- Getting all functions assigned to a position
	SELECT bpFun.NM_FUNCTION, bpFun.KY_TYPE_FUNCTION
	FROM ADM.C_POSITION pos
	INNER JOIN ADM.C_POSITION_FUNCTION posFun ON pos.ID_POSITION = posFun.ID_POSITION
	INNER JOIN ADM.C_BRANCH_PLANT_FUNCTION bpFun ON bpFun.ID_FUNCTION = posFun.ID_FUNCTION
	WHERE pos.ID_POSITION = @V_ID_POSITION
END

