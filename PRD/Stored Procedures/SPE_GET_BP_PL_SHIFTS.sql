-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - VITEK - 2020
-- Author: Francisco Javier Oñate Manrique
-- Create date: 06/08/2020
-- Description: SPE Aux for BackDoor--,
--				Gets all the BranchPlants, ProductionLines,
--				their corresponding shifts and start time of the shift
-- =============================================
-- =============================================
CREATE PROCEDURE [PRD].[SPE_GET_BP_PL_SHIFTS] 

	
AS
BEGIN
	SET NOCOUNT ON;
	-- RETURNS THE NEXT SET OF VALUES:
	-- [ID_BRANCH_PLANT] INT
	-- [KY_BRANCH_PLANT] VARCHAR
	-- [ID_PRODUCTION_LINE] INT
	-- [SHIFT] VARCHAR
	-- [START_TIME] TIME
	-- [END_TIME] TIME


	DECLARE @AuxShift TABLE (
	[ID_I]int IDENTITY(1,1),
	[ID] int,
	[SHIFT] varchar(50),
	[START_TIME] time,
	[END_TIME] time)
		insert into @AuxShift ([ID],[SHIFT]) select ID_PRODUCTION_LINE, KY_SHIFT from [PRD].[K_SHIFT] where KY_SHIFT != '' group by ID_PRODUCTION_LINE, KY_SHIFT order by ID_PRODUCTION_LINE

	DECLARE @AuxIdI int = 1;
	while (@AuxIdI <= (select count([ID_I]) from @AuxShift))
		BEGIN
			update @AuxShift set [START_TIME] =  convert (time,(select top 1 DT_START_SHIFT from[PRD].[K_SHIFT] where KY_SHIFT = (select [SHIFT] from @AuxShift where [ID_I] =@AuxIdI))) 
							where [ID_I] = @AuxIdI

			update @AuxShift set [END_TIME] =  convert (time,(select top 1 DT_END_SHIFT from[PRD].[K_SHIFT] where KY_SHIFT = (select [SHIFT] from @AuxShift where [ID_I] =@AuxIdI))) 
							where [ID_I] = @AuxIdI

			set @AuxIdI = @AuxIdI + 1;
		END


	select bp.[ID_BRANCH_PLANT],bp.[KY_BRANCH_PLANT], pl.ID_PRODUCTION_LINE, sh.[SHIFT], sh.[START_TIME], sh.[END_TIME]
	from [ADM].[C_BRANCH_PLANT] as bp
	 left join PRD.C_PRODUCTION_LINE as pl on bp.ID_BRANCH_PLANT = pl.ID_BRANCH_PLANT
	 left join @AuxShift as sh on sh.ID = pl.ID_PRODUCTION_LINE order by bp.ID_BRANCH_PLANT,pl.ID_PRODUCTION_LINE,sh.[SHIFT] asc

END
