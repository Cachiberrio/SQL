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