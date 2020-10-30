CREATE FUNCTION [dbo].[GetNewPathLocator] (@parent hierarchyid = null) RETURNS varchar(max) AS
BEGIN       
    DECLARE @result varchar(max), @newid uniqueidentifier  -- declare new path locator, newid placeholder       
    SELECT @newid = new_id from dbo.GETNEWID -- retrieve new GUID      
    SELECT @result = ISNULL(@parent.ToString(), '/') + -- append parent if present, otherwise assume root
                     convert(varchar(20), convert(bigint, substring(convert(binary(16), @newid), 1, 6))) + '.' +
                     convert(varchar(20), convert(bigint, substring(convert(binary(16), @newid), 7, 6))) + '.' +
                     convert(varchar(20), convert(bigint, substring(convert(binary(16), @newid), 13, 4))) + '/'     
    RETURN @result -- return new path locator     
END
