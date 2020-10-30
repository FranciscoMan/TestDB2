-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - VITEK - 2020
-- Author: Francisco Javier Oñate Manrique
-- Create date: 07/08/2020
-- Description: SPE THAT DELETES ISSUES OR REDUCE THEM USING
--				THE HOUR BLOCK VALUES, DATE AND THEIR ID'S
-- =============================================
CREATE PROCEDURE [PRD].[SPE_DELETE_ISSUES_BY_HOURS]
	 @XML_RESULT XML = '' OUT,
	 @ID_BRANCH_PLANT as int,
	 @ID_PRODUCTION_LINE as int,
	 @DATE as date,
	 @HOURS as nvarchar(150),
	 @SHIFT as nvarchar(5), 
	 @KY_USER as nvarchar(50),
	 @NM_PROGRAM as nvarchar(50)

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @AcDate datetime = sysdatetime();
	

	-- RETRIEVING THE START AND END DATE OF THE SHIFT
	DECLARE @StartShift datetime = (select DT_START_SHIFT from [PRD].[K_SHIFT] where KY_SHIFT = @SHIFT AND
																					ID_BRANCH_PLANT = @ID_BRANCH_PLANT AND
																					ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE AND
																					(convert (date,DT_START_SHIFT)) = (convert (date,@DATE)) );


	-- Aux table to dump the hour blocks to update.
	DECLARE @AuxHours TABLE (
	[ID_I] int IDENTITY (1,1),
	[HOUR] float)
	-- reader to search for the hours in a format like 'H,H,...H,' where H is an Hour block, always needs to end with a ','
	DECLARE @top int = datalength(@HOURS);
	DECLARE @coma int = 1;
	DECLARE @moving int = 1;

	DECLARE @Haux varchar(5) = '';
	WHILE(@top >= @moving AND @top >= @coma)
		BEGIN
			if ( SUBSTRING(@HOURS,@moving,1) = ',' )
				BEGIN
					insert into @AuxHours ([HOUR]) values (convert(float,@Haux));
					set @coma = @moving;
					set @Haux = '';
				END
			else
				BEGIN
					set @Haux = @Haux + SUBSTRING(@HOURS,@moving,1);
				END
			set @moving = @moving + 1;
		END


	
	--process
	set @top = (select count([ID_I]) from @AuxHours)
	set @moving = 1;

	DECLARE @AuxIdIssue int;
	DECLARE @AuxEnd int;


	WHILE (@moving <= @top)
		BEGIN
			set @AuxIdIssue = (select top 1 i.ID_ISSUE from PRD.K_ISSUE as i join PRD.K_WORK_ORDER as w ON i.ID_WORK_ORDER = w.ID_WORK_ORDER 
								where i.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE AND w.ID_BRANCH_PLANT = @ID_BRANCH_PLANT AND i.DT_ISSUE 
								BETWEEN (DATEADD(n,(select [HOUR] from @AuxHours where ID_I = @moving)*60,@StartShift)) AND 
								(DATEADD(n,((select [HOUR] from @AuxHours where ID_I = @moving)*60)+30,@StartShift)))
				
				WHILE(@AuxIdIssue > 0)
					BEGIN 
						BEGIN TRY
							IF (@@TRANCOUNT = 0) 
								BEGIN
									BEGIN TRANSACTION
										-- Update if the block is in the Start date of the issue
										update PRD.K_ISSUE set DT_ISSUE = DATEADD(n,((select [HOUR] from @AuxHours where ID_I = @moving)*60)+31,@StartShift),
																KY_USER_APP_UPDATE = @KY_USER, NM_PROGRAM_UPDATE = @NM_PROGRAM, DT_UPDATE = @AcDate
															where ID_ISSUE = @AuxIdIssue;
										SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
										SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso completado', 'ES')
										SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successfull process', 'EN')
										COMMIT
								END
						END TRY
						BEGIN CATCH			
							ROLLBACK
								SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())
						END CATCH
						-- check if the Issue needs to be deleted
						if ( (select DT_ISSUE from PRD.K_ISSUE where ID_ISSUE= @AuxIdIssue) >= (select DT_ISSUE_CLOSED from PRD.K_ISSUE where ID_ISSUE= @AuxIdIssue) )
							BEGIN
								BEGIN TRY
									IF (@@TRANCOUNT = 0) 
										BEGIN
											BEGIN TRANSACTION
												-- deletes the issue only if needed
												delete PRD.K_ISSUE where ID_ISSUE = @AuxIdIssue;
												SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
												SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso completado', 'ES')
												SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successfull process', 'EN')
												COMMIT
										END
								END TRY
								BEGIN CATCH			
									ROLLBACK
										SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())
								END CATCH

							END
						-- check if there are overlaps on the hour block, if that is the case repeats the process
						set @AuxIdIssue = (select top 1 i.ID_ISSUE from PRD.K_ISSUE as i join PRD.K_WORK_ORDER as w ON i.ID_WORK_ORDER = w.ID_WORK_ORDER 
								where i.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE AND w.ID_BRANCH_PLANT = @ID_BRANCH_PLANT AND i.DT_ISSUE 
								BETWEEN (DATEADD(n,(select [HOUR] from @AuxHours where ID_I = @moving)*60,@StartShift)) AND 
								(DATEADD(n,((select [HOUR] from @AuxHours where ID_I = @moving)*60)+30,@StartShift)))
					END

			-- moves the pointer
			set @moving = @moving + 1;
		END

	-- Updating the End Hours
	set @moving = @top
	
	WHILE (@moving > 0)
	BEGIN
		set @AuxEnd = (select top 1 i.ID_ISSUE from PRD.K_ISSUE as i join PRD.K_WORK_ORDER as w ON i.ID_WORK_ORDER = w.ID_WORK_ORDER 
							where i.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE AND w.ID_BRANCH_PLANT = @ID_BRANCH_PLANT AND i.DT_ISSUE_CLOSED 
							BETWEEN (DATEADD(n,(select [HOUR] from @AuxHours where ID_I = @moving)*60,@StartShift)) AND 
							(DATEADD(n,((select [HOUR] from @AuxHours where ID_I = @moving)*60)+30,@StartShift)))
				
			WHILE(@AuxEnd > 0)
				BEGIN 
					BEGIN TRY
						IF (@@TRANCOUNT = 0) 
							BEGIN
								BEGIN TRANSACTION
									-- Update if the block is in the End date of the issue
									update PRD.K_ISSUE set DT_ISSUE_CLOSED = DATEADD(n,((select [HOUR] from @AuxHours where ID_I = @moving)*60)-1,@StartShift),
															KY_USER_APP_UPDATE = @KY_USER, NM_PROGRAM_UPDATE = @NM_PROGRAM, DT_UPDATE = @AcDate
														where ID_ISSUE = @AuxEnd;
									SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
									SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso completado', 'ES')
									SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successfull process', 'EN')
									COMMIT
							END
					END TRY
					BEGIN CATCH			
						ROLLBACK
							SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())
					END CATCH	
					-- check if the Issue needs to be deleted
					if ( (select DT_ISSUE from PRD.K_ISSUE where ID_ISSUE= @AuxEnd) >= (select DT_ISSUE_CLOSED from PRD.K_ISSUE where ID_ISSUE= @AuxEnd) )
						BEGIN
							BEGIN TRY
								IF (@@TRANCOUNT = 0) 
									BEGIN
										BEGIN TRANSACTION
											-- deletes the issue only if needed
											delete PRD.K_ISSUE where ID_ISSUE = @AuxEnd;
											SET @XML_RESULT = DBO.F_ERROR_CREATE_HEADER( @@ROWCOUNT, 1, 'SUCCESSFUL')
											SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Proceso completado', 'ES')
											SET @XML_RESULT = DBO.F_ERROR_INSERT_MESSAGES(@XML_RESULT, 'Successfull process', 'EN')
											COMMIT
									END
							END TRY
							BEGIN CATCH			
								ROLLBACK
									SET @XML_RESULT = DBO.F_ERROR_MESSAGES(ERROR_NUMBER(), ERROR_MESSAGE())
							END CATCH

						END
					-- check if there are overlaps on the hour block, if that is the case repeats the process
					set @AuxEnd = (select top 1 i.ID_ISSUE from PRD.K_ISSUE as i join PRD.K_WORK_ORDER as w ON i.ID_WORK_ORDER = w.ID_WORK_ORDER 
							where i.ID_PRODUCTION_LINE = @ID_PRODUCTION_LINE AND w.ID_BRANCH_PLANT = @ID_BRANCH_PLANT AND i.DT_ISSUE_CLOSED 
							BETWEEN (DATEADD(n,(select [HOUR] from @AuxHours where ID_I = @moving)*60,@StartShift)) AND 
							(DATEADD(n,((select [HOUR] from @AuxHours where ID_I = @moving)*60)+30,@StartShift)))
				END

		-- moves the pointer
		set @moving = @moving - 1;
	END
	
END
