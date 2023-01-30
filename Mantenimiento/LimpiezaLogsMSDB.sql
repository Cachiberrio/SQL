/* Limpieza msdb de ficheros de log del agente
Vacia las tablas de logs de Agente en la BD MSDB y reduce el fichero

*/

declare @dt datetime select @dt = cast(N'2015-11-06T11:54:45' as datetime) exec msdb.dbo.sp_delete_backuphistory @dt
GO
EXEC msdb.dbo.sp_purge_jobhistory  @oldest_date='2015-11-06T11:54:45'
GO
EXECUTE msdb..sp_maintplan_delete_log null,null,'2015-11-06T11:54:45'

ALTER TABLE [dbo].[sysmaintplan_log] DROP CONSTRAINT [FK_sysmaintplan_log_subplan_id];
ALTER TABLE [dbo].[sysmaintplan_logdetail] DROP CONSTRAINT [FK_sysmaintplan_log_detail_task_id];
truncate table msdb.dbo.sysmaintplan_logdetail;
truncate table msdb.dbo.sysmaintplan_log;
ALTER TABLE [dbo].[sysmaintplan_log] WITH CHECK ADD CONSTRAINT [FK_sysmaintplan_log_subplan_id] FOREIGN KEY([subplan_id])
REFERENCES [dbo].[sysmaintplan_subplans] ([subplan_id]);
ALTER TABLE [dbo].[sysmaintplan_logdetail] WITH CHECK ADD CONSTRAINT [FK_sysmaintplan_log_detail_task_id] FOREIGN KEY([task_detail_id])
REFERENCES [dbo].[sysmaintplan_log] ([task_detail_id]) ON DELETE CASCADE;

--- SHRINK THE MSDB LOG FILE
USE MSDB
GO
DBCC SHRINKFILE(MSDBLog, 512)
GO
-- SHRINK THE MSDB Data File
USE MSDB
GO
DBCC SHRINKFILE(MSDBData, 1024)
GO
