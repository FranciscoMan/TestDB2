-- =============================================
-- Author:		<Christian,Moreno>
-- Create date: <04/21/2020,,>
-- Description:	<Obtener las mediciones de formulario soc por qa27,,>
-- =============================================
CREATE PROCEDURE [PRD].[SPE_GET_SAVEREPORT]
	@PIN_SHIFT AS NVARCHAR(50),
	@PIN_DT AS DATETIME
AS
BEGIN

	IF @PIN_SHIFT = 'SF-3'
	SELECT KQA.REPORT
	FROM PRD.SAVEREPORT KQA 
	WHERE KQA.DT_REPORT = @PIN_DT
	
	ELSE
	SELECT KQA.REPORT
	FROM PRD.SAVEREPORT KQA 
	WHERE KQA.NM_SHIFT = @PIN_SHIFT AND KQA.DT_REPORT = @PIN_DT
	
END
