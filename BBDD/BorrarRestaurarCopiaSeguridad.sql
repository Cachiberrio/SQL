USE [master]

BEGIN -- Borrado de la base de datos
	IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'MyDatabase') BEGIN
		DECLARE @dbId int
		DECLARE @isStatAsyncOn bit
		DECLARE @jobId int
		DECLARE @sqlString nvarchar(500)

		SELECT @dbId = database_id,
			   @isStatAsyncOn = is_auto_update_stats_async_on
		FROM sys.databases
		WHERE name = 'CEPDW'

		IF @isStatAsyncOn = 1
		BEGIN
			ALTER DATABASE [CEPDW] SET  AUTO_UPDATE_STATISTICS_ASYNC OFF

			-- kill running jobs
			DECLARE jobsCursor CURSOR FOR
			SELECT job_id
			FROM sys.dm_exec_background_job_queue
			WHERE database_id = @dbId

			OPEN jobsCursor

			FETCH NEXT FROM jobsCursor INTO @jobId
			WHILE @@FETCH_STATUS = 0
			BEGIN
				set @sqlString = 'KILL STATS JOB ' + STR(@jobId)
				EXECUTE sp_executesql @sqlString
				FETCH NEXT FROM jobsCursor INTO @jobId
			END

			CLOSE jobsCursor
			DEALLOCATE jobsCursor
		END

		ALTER DATABASE [CEPDW] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE

		DROP DATABASE [CEPDW]
	END
END
BEGIN -- Restauración copia de seguridad
	RESTORE FILELISTONLY FROM DISK = 'D:\Compartida\AM\CEP\CEPDW.bak'

	RESTORE DATABASE [CEPDW] FROM DISK = 'D:\Compartida\AM\CEP\CEPDW.bak'
		WITH
			MOVE 'CEPDW' TO 'D:\BBDD\Data_2k19\CEPDW.mdf',
			MOVE 'CEPDW_Log' TO 'D:\BBDD\Data_2k19\CEPDW_Log.ldf',
		RECOVERY, REPLACE, STATS = 10
END