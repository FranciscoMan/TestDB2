-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - VITEK - 2019
-- Author: Jose Donaldo LG
-- CREATE date: 08/29/2019
-- Description: get all event table
-- =============================================

CREATE PROCEDURE    [PRD].[SPE_K_EVENT_TABLE]
@PIN_NM_EVENT AS NVARCHAR(100) = null
AS

SELECT * FROM PRD.K_EVENT_TABLE ET
WHERE (@PIN_NM_EVENT IS NULL OR(@PIN_NM_EVENT IS NOT NULL AND(ET.EVENT_NAME = @PIN_NM_EVENT)))




