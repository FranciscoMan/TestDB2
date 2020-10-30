-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author:		Gabriel Vázquez Torres
-- Create date: 14/05/2018
-- Description:	Get values for hysteresis
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_HYSTERESIS_VALUE]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 	    
		HT.ID_HYSTERESIS_TYPE,
		HT.KY_HYSTERESIS_TYPE,
		HT.NM_HYSTERESIS_TYPE		
	FROM ADM.VW_C_HYSTERESIS_TYPE HT
	ORDER BY HT.KY_HYSTERESIS_TYPE
END

