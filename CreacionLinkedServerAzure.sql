EXEC master.dbo.sp_addlinkedserver
@server = N'sql2ak.database.windows.net',
@srvproduct=N'',
  @provider=N'SQLNCLI',
   @datasrc=N'sql2ak.database.windows.net',
    @catalog=N'AK2016'
/* For security reasons, the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin
@rmtsrvname=N'sql2ak.database.windows.net',
@useself=N'False',
@locallogin=NULL,
@rmtuser=N'sql-tipsa',@rmtpassword='A8brn&PfsRN5'
GO

EXEC master.dbo.sp_serveroption @server=N'sql2ak.database.windows.net', @optname=N'rpc', @optvalue=N'true'
GO
EXEC master.dbo.sp_serveroption @server=N'sql2ak.database.windows.net', @optname=N'rpc out', @optvalue=N'true'
GO

/*
Serv BD: sql2ak.database.windows.net
BD: AK2016
Usuario: sql-tipsa
Pass: A8brn&PfsRN5
*/