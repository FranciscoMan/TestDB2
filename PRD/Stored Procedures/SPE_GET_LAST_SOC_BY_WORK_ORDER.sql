-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Vitek - 2020
-- Author: Aideé Alvarez.
-- CREATE date: 02/17/2020
-- Description: GET LAST SOC OF WORK ORDER.
-- =============================================

CREATE PROCEDURE   [PRD].[SPE_GET_LAST_SOC_BY_WORK_ORDER]
	@PIN_QA27 INT = NULL,			   -- QA27 de la work order en estatus complete.
	@PIN_ID_PRODUCTION_LINE INT = NULL, -- Qué línea de producción es.
	@RESULT BIT OUTPUT
	AS
BEGIN
	DECLARE 
	 @WO INT
	, @ITEM_PROG INT -- ITEM DE LA WO SCHED
	, @ITEM_ACTUAL INT -- ITEM DE LA WO INGRESADA
	, @WO_ACTUAL INT
	, @STATUS VARCHAR(30)
	, @KFORM INT
  --, @PIN_QA27 INT = 16010 
  --, @PIN_ID_PRODUCTION_LINE INT = 2211001
	
	-- 1.- Trae el item de la work order que sigue en esa línea de producción (Scheduled).
	SELECT TOP 1
	 @WO = WO.ID_WORK_ORDER,
	 @ITEM_PROG = WO.ID_ITEM
	FROM PRD.K_WORK_ORDER WO 
	WHERE WO.KY_STATUS = 'SCHEDULED' AND WO.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE
	ORDER BY DT_WORK_ORDER ASC
	
	-- 2. Traer el item y la work order de la qa27 en status complete.
	SELECT 
	  @ITEM_ACTUAL= WO.ID_ITEM
	, @WO_ACTUAL = QA.ID_WORK_ORDER
	FROM PRD.K_WORK_ORDER WO 
	INNER JOIN PRD.K_QA27 QA ON WO.ID_WORK_ORDER = QA.ID_WORK_ORDER
	WHERE QA.ID_QA27 = @PIN_QA27  AND (WO.KY_STATUS = 'COMPLETE' OR WO.KY_STATUS = 'RUNNING')

  -- SELECT @ITEM_PROG ITEM_PROGRAMADA, @WO WO_PROGRAMADA, @ITEM_ACTUAL ITEM_ACTUAL, @WO_ACTUAL WO_ACTUAL , @PIN_QA27 QA_ACTUAL-- PRUEBA
    -- 3. Compara los items. Si es un si, entonces no hay problema, solo si la work order es la misma.


	IF(@WO_ACTUAL <> @WO) -- Si las work order son diferentes... 
		BEGIN
		-- Cae en los casos de que las wo son diferentes y los items iguales; wo diferentes e items diferentes.
			 IF (@ITEM_ACTUAL <> @ITEM_PROG OR (@ITEM_ACTUAL = @ITEM_PROG)) 
			 BEGIN
			 -- La bandera contendrá aquellos que si tienen un captured, que en si es el último registrado.

			 SELECT TOP 1 @KFORM   = F.ID_K_FORM, 
			 @STATUS = F.KY_STATUS_FORM 
			 FROM PRD.K_FORM F  INNER JOIN PRD.K_FORM_METRICS KFM ON KFM.ID_K_FORM = F.ID_K_FORM
			 INNER JOIN PRD.K_WORK_ORDER W ON W.ID_WORK_ORDER=F.ID_WORK_ORDER
			 WHERE W.ID_PRODUCTION_LINE = @PIN_ID_PRODUCTION_LINE AND W.ID_WORK_ORDER=@WO_ACTUAL  AND ID_FORM=3 AND W.ID_ITEM =@ITEM_ACTUAL
			 AND KFM.ID_METRICS=66  AND F.KY_STATUS_FORM = 'CAPTURED' ORDER BY F.DT_FORM DESC

			--  SELECT TOP 1 
			--@KFORM   = KF.ID_K_FORM, 
			-- @STATUS = KF.KY_STATUS_FORM  
			--  FROM PRD.K_WORK_ORDER WO INNER JOIN PRD.K_FORM KF ON 
			--		KF.ID_WORK_ORDER = WO.ID_WORK_ORDER  WHERE WO.ID_WORK_ORDER = @WO_ACTUAL AND   KY_STATUS_FORM = 'CAPTURED' AND KF.ID_FORM=3
			--		GROUP BY WO.ID_WORK_ORDER, KF.ID_K_FORM, KF.KY_STATUS_FORM	ORDER BY ID_K_FORM  DESC 
			 END
		END
	ELSE 
	-- Las work order son iguales así como sus item.
		BEGIN 
		   IF(@ITEM_ACTUAL = @ITEM_PROG)
		   BEGIN
			PRINT N'SON WO IGUALES, ITEMS IGUALES' 
			SET @RESULT =  1
		   END
		END
	
	-- Mandamos 1 o 0 para saber si cambia o necesita agregar mediciones.
    IF (@STATUS IS NULL AND @KFORM  IS NULL)
	SET @RESULT = 0  -- Está vacío. Tiene mediciones pero no son captured.
	ELSE 
	BEGIN
	--SELECT @KFORM K_FORM, @STATUS STATUS_FORM, @WO_ACTUAL WORK_ORDER_COMPLETE
	SET @RESULT =  1 -- Tiene medición.
	END
END
