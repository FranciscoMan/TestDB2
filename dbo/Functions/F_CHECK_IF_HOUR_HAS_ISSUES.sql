-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - VITEK - 2019
-- Author: Francisco Javier Oñate Manrique
-- Create date: 22/07/2020
-- Description: FUNCTION AUX OF ADD-On 170,
--				RETURNS 1 IF THE HOUR IN FLOAT FORMAT
--				IS IN A ISSUE EVENT BETWEEN THE DATES
-- =============================================
CREATE FUNCTION [dbo].[F_CHECK_IF_HOUR_HAS_ISSUES] 
(
	 @Start_Date datetime,
	 @End_Date datetime,
	 @Hour float,
	 @ID_PL INT
)
RETURNS bit
AS
BEGIN
	

	DECLARE @Check bit =0
	DECLARE @AuxHour datetime
	DECLARE @AuxHourEnd datetime

	SET @AuxHour = DATEADD(MINUTE,@Hour*60,@Start_Date)
	SET @AuxHourEnd = DATEADD(MINUTE,(@Hour*60)+30,@Start_Date)

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
				where convert (date,[DT_ISSUE]) = convert (date,@Start_Date) 
						AND DT_ISSUE < @End_Date AND ID_PRODUCTION_LINE = @ID_PL
				order by DT_ISSUE asc;


	DECLARE @AuxIDI int = 1
	DECLARE @AuxCount int = (select count(ID_I) from @AuxIssue)


	DECLARE @BI int
	DECLARE @BF int
	DECLARE @II int
	DECLARE @IF int
	DECLARE @AuxHH varchar
	DECLARE @AuxMM varchar

	DECLARE @AuxSH datetime
	DECLARE @AuxEH datetime
	--UPDATE TO TAKE IN CONSIDERATION THE DAY + HOUR + MINUTES, JUST IN CASE
	--IF THE USE OF THE DAY GENERATES PROBLEMS YOU CAN JUST DELETE THE FIRST CASE IN EVERY SET AND SHOULD DO THE TRICK
	WHILE @AuxCount >0
		BEGIN
			set @AuxSH = (select [DT_ISSUE] from @AuxIssue where ID_I=@AuxIDI)
			set @AuxEH = (select [DT_ISSUE_CLOSED] from @AuxIssue where ID_I=@AuxIDI)

			set @BI = convert(int,(
			case when  DATALENGTH(convert(varchar,datepart(dd,@AuxHour)))  =1 then '0'+convert(varchar,datepart(dd,@AuxHour))
				 when  DATALENGTH(convert(varchar,datepart(dd,@AuxHour))) !=1 then     convert(varchar,datepart(dd,@AuxHour))END +  
			case when  DATALENGTH(convert(varchar,datepart(hh,@AuxHour)))  =1 then '0'+convert(varchar,datepart(hh,@AuxHour))
				 when  DATALENGTH(convert(varchar,datepart(hh,@AuxHour))) !=1 then     convert(varchar,datepart(hh,@AuxHour))END +  
			case when  DATALENGTH(convert(varchar,datepart(n, @AuxHour)))  =1 then '0'+convert(varchar,datepart(n, @AuxHour))
				 when  DATALENGTH(convert(varchar,datepart(n, @AuxHour))) !=1 then     convert(varchar,datepart(n, @AuxHour))END ))

			set @BF = convert(int,(
			case when  DATALENGTH(convert(varchar,datepart(dd,@AuxHourEnd)))  =1 then '0'+convert(varchar,datepart(dd,@AuxHourEnd))
				 when  DATALENGTH(convert(varchar,datepart(dd,@AuxHourEnd))) !=1 then     convert(varchar,datepart(dd,@AuxHourEnd))END +  
			case when  DATALENGTH(convert(varchar,datepart(hh,@AuxHourEnd)))  =1 then '0'+convert(varchar,datepart(hh,@AuxHourEnd))
				 when  DATALENGTH(convert(varchar,datepart(hh,@AuxHourEnd))) !=1 then     convert(varchar,datepart(hh,@AuxHourEnd))END +  
			case when  DATALENGTH(convert(varchar,datepart(n, @AuxHourEnd)))  =1 then '0'+convert(varchar,datepart(n, @AuxHourEnd))
				 when  DATALENGTH(convert(varchar,datepart(n, @AuxHourEnd))) !=1 then     convert(varchar,datepart(n, @AuxHourEnd))END ))

			set @II = convert(int,(
			case when  DATALENGTH(convert(varchar,datepart(dd,@AuxSH)))  =1 then '0'+convert(varchar,datepart(dd,@AuxSH))
				 when  DATALENGTH(convert(varchar,datepart(dd,@AuxSH))) !=1 then     convert(varchar,datepart(dd,@AuxSH))END +  
			case when  DATALENGTH(convert(varchar,datepart(hh,@AuxSH)))  =1 then '0'+convert(varchar,datepart(hh,@AuxSH))
				 when  DATALENGTH(convert(varchar,datepart(hh,@AuxSH))) !=1 then     convert(varchar,datepart(hh,@AuxSH))END +  
			case when  DATALENGTH(convert(varchar,datepart(n, @AuxSH)))  =1 then '0'+convert(varchar,datepart(n, @AuxSH))
				 when  DATALENGTH(convert(varchar,datepart(n, @AuxSH))) !=1 then     convert(varchar,datepart(n, @AuxSH))END ))

			set @IF = convert(int,(
			case when  DATALENGTH(convert(varchar,datepart(dd,@AuxEH)))  =1 then '0'+convert(varchar,datepart(dd,@AuxEH))
				 when  DATALENGTH(convert(varchar,datepart(dd,@AuxEH))) !=1 then     convert(varchar,datepart(dd,@AuxEH))END +  
			case when  DATALENGTH(convert(varchar,datepart(hh,@AuxEH)))  =1 then '0'+convert(varchar,datepart(hh,@AuxEH))
				 when  DATALENGTH(convert(varchar,datepart(hh,@AuxEH))) !=1 then     convert(varchar,datepart(hh,@AuxEH))END +  
			case when  DATALENGTH(convert(varchar,datepart(n, @AuxEH)))  =1 then '0'+convert(varchar,datepart(n, @AuxEH))
				 when  DATALENGTH(convert(varchar,datepart(n, @AuxEH))) !=1 then     convert(varchar,datepart(n, @AuxEH))END ))
	
			if((@BI >= @II AND
				@BI < @IF)
				OR
				(@BF > @II AND
				@BF <= @IF))
				BEGIN
				set @Check = 1; return @Check;
				END

			set @AuxIDI = @AuxIDI +1 
			set @AuxCount = @AuxCount -1
		END

	RETURN @Check;

END