-- =============================================
-- Proyecto: Plaskolite
-- Copyright (c) - Acrux - 2017
-- Author: Julio Díaz
-- CREATE date: 26/02/2018
-- Description: Raise error
-- =============================================

CREATE PROCEDURE    [ADM].[SPE_RAISE_ERROR]
AS
BEGIN
	    
    /* return if there is no error information to retrieve. */
    
    if error_number() is null
        return;

    declare
        @errormessage    nvarchar(4000),
        @errornumber     int,
        @errorseverity   int,
        @errorstate      int,
        @errorline       int,
        @errorprocedure  nvarchar(200); 

    /* assign variables to error-handling functions that capture information for raiserror. */

    select
        @errornumber = error_number(),
        @errorseverity = error_severity(),
        @errorstate = error_state(),
        @errorline = error_line(),
        @errorprocedure = isnull(error_procedure(), '-'); 

    /* building the message string that will contain original error information. */

    select @errormessage = N'error %d, level %d, state %d, procedure %s, line %d, ' + 'message: '+ error_message(); 
        
    /* raise an error: msg_str parameter of raiserror will contain the original error information. */

    if @errornumber = 50001
    begin
		raiserror(
			@errornumber,    /* parameter: original error number. */
			@errorseverity,  /* parameter: original error severity. */
			@errorstate,     /* parameter: original error state. */
			@errorprocedure, /* parameter: original error procedure name. */
			@errorline       /* parameter: original error line number. */
			);
    end
    else
    begin
		raiserror(@errormessage, @errorseverity, 1,
			@errornumber,    /* parameter: original error number. */
			@errorseverity,  /* parameter: original error severity. */
			@errorstate,     /* parameter: original error state. */
			@errorprocedure, /* parameter: original error procedure name. */
			@errorline       /* parameter: original error line number. */
			);
    end

END

