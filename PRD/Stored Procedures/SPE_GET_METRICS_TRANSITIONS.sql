-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 21/05/2018
-- Description: Get transitions-metrics relationships
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_METRICS_TRANSITIONS] 
	@PIN_ID_METRICS INT
AS

SELECT CMT.ID_METRICS_TRANSITION
	, CT.ID_TRANSITION
	, CT.KY_TRANSITION
	, CT.NM_TRANSITION
	, CT.DS_TRANSITION
	, CT.NO_STANDARD_TIME
FROM PRD.C_TRANSITION CT
	INNER JOIN PRD.C_METRICS_TRANSITION CMT
		ON CT.ID_TRANSITION = CMT.ID_TRANSITION
WHERE CMT.ID_METRICS = @PIN_ID_METRICS

