-- =============================================
-- Proyect: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio César Tavares
-- CREATE date: 23/03/2017
-- Description: get all forms
-- =============================================
CREATE PROCEDURE    [ADM].[SPE_GET_DATA_ACQUISITION_ORIGIN] 

AS   
	SELECT VDA.ID_DATA_ACQUISITION_ORIGIN,  VDA.KY_DATA_ACQUISITION_ORIGIN, VDA.NM_DATA_ACQUISITION_ORIGIN
	  FROM ADM.VW_C_DATA_ACQUISITION_ORIGIN VDA


