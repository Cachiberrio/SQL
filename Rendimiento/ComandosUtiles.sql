
-- Ver tamaño de todas las tablas

SELECT
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB,
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM
    sys.tables t
INNER JOIN
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN
    sys.schemas s ON t.schema_id = s.schema_id
WHERE
    t.NAME NOT LIKE 'dt%'
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
GROUP BY
    t.Name, s.Name, p.Rows
ORDER BY
    TotalSpaceMB DESC, t.Name



-- ver conexiones activas
exec sp_who
exec sp_who2


 SELECT
    r.session_id as SessionID,
    r.start_time as StartTime,
    r.[status] as Status,
    r.wait_type as WaitType,
    r.blocking_session_id as BlockedBySessionID,
    sessions.login_name as BlockedByUser,
    SUBSTRING(qt.[text],r.statement_start_offset / 2,
        (CASE
            WHEN r.statement_end_offset = -1
            THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2
            ELSE r.statement_end_offset
            END - r.statement_start_offset) / 2) AS SQLStatement,
    DB_NAME(qt.[dbid]) AS DatabaseName,
    r.cpu_time as CPUTime,
    r.total_elapsed_time as TotalElapsedTime,
    Round(r.total_elapsed_time / 1000.0 / 60.0,1) as TotalElapsedTimeInMinutes,
    r.reads as Reads,
    r.writes as Write,
    r.logical_reads as LogicalReads
FROM sys.dm_exec_requests AS r
    OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS qt
    LEFT OUTER JOIN sys.dm_exec_sessions sessions ON sessions.session_id = r.blocking_session_id
WHERE r.session_id > 50 -- This eliminates system requests
ORDER BY r.start_time

-- cerrrar conexión
KILL ID
