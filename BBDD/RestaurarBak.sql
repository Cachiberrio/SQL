/* Script para restaurar bak con move

 Para ver estructura de un BACKUP */
RESTORE FILELISTONLY FROM DISK = 'fichero.bak'




USE [master]
GO

RESTORE DATABASE [AdventureWorksCopy] FROM DISK = 'c:\mssql\backup\yukon\AW2K5_Full.bak'
WITH
MOVE 'AdventureWorks_Data' TO 'c:\mssql\data\yukon\AdventureWorksCopy_Data.mdf',
MOVE 'AdventureWorks_Log' TO 'c:\mssql\log\yukon\AdventureWorksCopy_Log.ldf',
RECOVERY, REPLACE, STATS = 10;

/* Restaurar con diferenciales con move */
