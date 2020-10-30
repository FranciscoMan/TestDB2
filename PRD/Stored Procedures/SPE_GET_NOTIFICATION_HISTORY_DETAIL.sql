-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2018
-- Author: Julio Tavares
-- CREATE date: 25/05/2018
-- Description: get notification history detail
-- =============================================
CREATE PROCEDURE    [PRD].[SPE_GET_NOTIFICATION_HISTORY_DETAIL]
	    @PIN_ID_NOTIFICATIONS AS int = NULL
AS   
	BEGIN
	DECLARE --@V_ID_NOTIFICATIONS INT = --1506, 
	--							1505, 

		@XML_PROCESS_CONFITURATION XML = NULL,
		@XML_PROCESS_RECIPENTS XML = NULL,
		@XML_USER_INVOLVED XML = NULL,
		@V_KY_PROCESS_TYPE NVARCHAR(100) = NULL,
		@V_KY_NOTIFICATION_ORIGIN NVARCHAR(100) = NULL,
		@V_DT_NOTIFICATION DATETIME= NULL,
		@V_DT_SENDED DATETIME = NULL,
		@V_DT_WAITING DATETIME = NULL

 SELECT @XML_PROCESS_CONFITURATION = XML_PROCESS_CONFIGURATION,
		@V_KY_PROCESS_TYPE = ISNULL(NP.KY_PROCESS_TYPE, '--'),
		@V_KY_NOTIFICATION_ORIGIN = NP.KY_NOTIFICATION_ORIGIN,
		@V_DT_NOTIFICATION = NP.DT_NOTIFICATION,
		@V_DT_SENDED = NP.DT_SENDED,
		@V_DT_WAITING = NP.DT_WAITING
   FROM PRD.K_NOTIFICATIONS_SENDED NP
  WHERE NP.ID_NOTIFICATION_SENDED = @PIN_ID_NOTIFICATIONS

	SELECT @XML_PROCESS_RECIPENTS = msgs.msg.query('.')
	  FROM @XML_PROCESS_CONFITURATION.nodes('NOTIFICATIONS/RECIPIENTS') msgs(msg) 

	SELECT @XML_PROCESS_CONFITURATION = msgs.msg.query('.')
	  FROM @XML_PROCESS_CONFITURATION.nodes('(/NOTIFICATIONS/*[1])') msgs(msg) 
	

	SET @XML_USER_INVOLVED =(
		SELECT ISNULL(CU.KY_USER,'--') AS "@KY_USER_INVOLVED",
			   ISNULL(CU.NM_USER,'--') AS "@NM_USER",
			   ISNULL(CE.NM_FIRST_NAME,'--') + ' '+ ISNULL(NM_LAST_NAME,'--') AS "@NM_FULL_NAME"
		  FROM(
  			  SELECT msgs.msg.value('@TO', 'nvarchar(max)') AS KY_USER_INVOLVED 
 			    FROM @XML_PROCESS_RECIPENTS.nodes('RECIPIENTS/RECIPIENT') msgs(msg) 
		      ) UI
		  JOIN ADM.C_USER CU ON UI.KY_USER_INVOLVED = CU.KY_USER
	 LEFT JOIN ADM.C_EMPLOYEE CE ON CU.ID_EMPLOYEE = CE.ID_EMPLOYEE
	FOR XML PATH ('USER'), ROOT ('USERS')
	)

	SELECT @V_KY_PROCESS_TYPE AS KY_PROCESS_TYPE,
		   @V_KY_NOTIFICATION_ORIGIN AS KY_NOTIFICATION_ORIGIN,
		   @V_DT_NOTIFICATION AS DT_NOTIFICATION,
		   @V_DT_SENDED AS DT_SENDED,
		   @V_DT_WAITING AS DT_WAITING,
	       DS_TITLE,
		   DS_MESSAGE,
		   KY_TYPE,
		   NM_NAME,
		   @XML_USER_INVOLVED USER_INVOLVED
 	  FROM(
	      SELECT 
				--ISNULL(msgs.msg.value('@TITLE', 'nvarchar(max)'),'--')  DS_TITLE ,
				--ISNULL(msgs.msg.value('@MESSAGE', 'nvarchar(max)'),'--')  DS_MESSAGE ,
				--ISNULL(msgs.msg.value('@TYPE', 'nvarchar(max)'),'--')  KY_TYPE ,
				--ISNULL(msgs.msg.value('@NAME', 'nvarchar(max)'),'--')  NM_NAME
				msgs.msg.value('@TITLE', 'nvarchar(max)')  DS_TITLE ,
				msgs.msg.value('@MESSAGE', 'nvarchar(max)')  DS_MESSAGE ,
				msgs.msg.value('@TYPE', 'nvarchar(max)')  KY_TYPE ,
				msgs.msg.value('@NAME', 'nvarchar(max)')  NM_NAME
				 -- msgs.msg.value('@TO', 'nvarchar(max)')  TO_USER 
		   ----FROM @XML_PROCESS_CONFITURATION.nodes('NOTIFICATIONS/child::node()') msgs(msg) 
		   FROM @XML_PROCESS_CONFITURATION.nodes('child::node()') msgs(msg) 
	)ALERT 
	GROUP BY DS_TITLE, DS_MESSAGE, KY_TYPE, NM_NAME
END

