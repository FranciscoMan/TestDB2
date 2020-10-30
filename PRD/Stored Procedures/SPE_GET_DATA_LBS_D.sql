
-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Gabriel Vázquez Torres
-- CREATE date: 08/01/2019
-- Description: get lbs 
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_GET_DATA_LBS_D]
 @INIT DATETIME,
 @XML_PRODUCTION_LINES XML
	
AS   
BEGIN		

 SELECT ID_PRODUCTION_LINE
		, ABS (NO_PRD_LBS) AS NO_PRD_LBS
		, NO_SVD_LBS
	FROM PRD.F_GET_PRODUCED_LBS_PER_LINE (@XML_PRODUCTION_LINES, @INIT)


END

