ALTER ROLE [db_owner] ADD MEMBER [usrQA27];


GO
ALTER ROLE [db_datareader] ADD MEMBER [rouser];


GO
ALTER ROLE [db_datareader] ADD MEMBER [usrQA27ro];


GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [rouser];


GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [usrQA27ro];

