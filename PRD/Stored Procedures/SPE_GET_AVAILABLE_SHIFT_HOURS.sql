-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - VITEK - 2019
-- Author: Francisco Javier Oñate Manrique
-- Create date: 22/07/2020
-- Description: SOTORED PROCEDURE THAT RETURNS
--				AVAILABLE HOURS OF THE SHIFT
--				USING ONLY A INITIAL DATE
-- =============================================
CREATE PROCEDURE [PRD].[SPE_GET_AVAILABLE_SHIFT_HOURS] 
	@DT_START datetime,
	 @ID_PL INT
AS
BEGIN
	-- RETURNS THIS SET OF COLUMNS AND DATATYPE
	--	[HOUR] float,
	--  [STATUS] vachar,

	SET NOCOUNT ON;



	DECLARE @DT_END datetime;
		IF(datepart(hh,@DT_START)>=12)
		BEGIN
			set @DT_END = convert(datetime,(convert (varchar,datepart(yyyy,@DT_START)) +'-'
							+convert (varchar,datepart(mm,@DT_START))+'-'
							+(convert(varchar,(datepart(dd,@DT_START)+1))) + ' 00:00:00.000'));
			set @DT_START= convert(datetime,convert (varchar,convert(date,@DT_START)) + ' 12:00:00.000');
		END
		else
		BEGIN
			set @DT_END = convert(datetime,convert (varchar,convert(date,@DT_START)) + ' 12:00:00.000');
			set @DT_START= convert(datetime,convert (varchar,convert(date,@DT_START)) + ' 00:00:00.000');
		END
	DECLARE @AuxIssue TABLE (
	   [ID_I] int IDENTITY(1,1)
	  ,[ID_QA27] int
      ,[ID_WORK_ORDER] int
      ,[ID_PRODUCTION_LINE] int
      ,[DT_ISSUE] datetime
      ,[DT_ISSUE_CLOSED] datetime )
	
	insert into @AuxIssue ([ID_QA27],[ID_WORK_ORDER],[ID_PRODUCTION_LINE],[DT_ISSUE],[DT_ISSUE_CLOSED])
		select [ID_QA27] 
              ,[ID_WORK_ORDER] 
              ,[ID_PRODUCTION_LINE] 
              ,[DT_ISSUE] 
              ,[DT_ISSUE_CLOSED] from [PRD].[K_ISSUE]
				where convert (date,[DT_ISSUE]) = convert (date,@DT_START) 
						AND DT_ISSUE < @DT_END AND ID_PRODUCTION_LINE = @ID_PL
				order by DT_ISSUE asc;

	DECLARE @AuxTHours TABLE (
		[ID_I] int IDENTITY(1,1),
		[HOUR] float,
		[STATUS] varchar(20),
		[DT1] datetime)

	DECLARE @AuxCounter int = 0;
	DECLARE @AuxHCounter float = 0;
		WHILE @AuxCounter < 24
			BEGIN
				insert into @AuxTHours ([HOUR]) 
					select @AuxHCounter;

				SET @AuxCounter = @AuxCounter + 1;
				SET @AuxHCounter = @AuxHCounter + 0.5;

			END
	DECLARE @AuxIDI int = 1
	DECLARE @AuxCount int = (select count(ID_I) from @AuxTHours)

	DECLARE @AuxCheck int
	DECLARE @AuxHour float

	
	WHILE @AuxCount>0
		BEGIN
			set @AuxHour =  (select [HOUR] from @AuxTHours where ID_I=@AuxIDI);
			update @AuxTHours set [DT1] = (DATEADD(MINUTE,@AuxHour*60,@DT_START)) where ID_I=@AuxIDI
			exec @AuxCheck = DBO.F_CHECK_IF_HOUR_HAS_ISSUES @DT_Start, @DT_END,@AuxHour, @ID_PL

			if(@AuxCheck=1)
			update @AuxTHours set [STATUS] = 'ISSUE' where ID_I=@AuxIDI
			else
			update @AuxTHours set [STATUS] = 'GOOD' where ID_I=@AuxIDI

			set @AuxIDI = @AuxIDI +1 
			set @AuxCount = @AuxCount -1
		END

	select [HOUR],[STATUS], [DT1] from @AuxTHours
END
