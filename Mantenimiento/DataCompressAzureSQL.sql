/* Script para comprobar qué tablas son susceptibles de activar la compresión de datos en Azure SQL
Es necesario ejecutar primero el script CrearFuncionesDataCompressSQLAzure.sql para generar varias funciones necesarias
*/

/* Top tablas por tamaño */
SELECT sys.objects.name, SUM(reserved_page_count) * 8.0 / 1024 as Size
FROM sys.dm_db_partition_stats, sys.objects
WHERE sys.dm_db_partition_stats.object_id = sys.objects.object_id
GROUP BY sys.objects.name
ORDER BY Size DESC;
GO



/* Comprobar la estimación compresión row / page */
EXEC usp_estimate_data_compression_savings
@schema_name = 'dbo'
,@object_name = 'LICORES BAINES$G_L Entry'
,@index_id = 1
,@partition_number = NULL
,@data_compression = 'PAGE'
GO

EXEC usp_estimate_data_compression_savings
@schema_name = 'dbo'
,@object_name = 'LICORES BAINES$G_L Entry'
,@index_id = 1
,@partition_number = NULL
,@data_compression = 'ROW'
GO

/* Información sobre los objetos con compresión activada */
SELECT o.name Table_Name, i.name as Index_Name, x.type_desc,
  CASE
    WHEN p.data_compression = 1 THEN 'ROW'
    WHEN p.data_compression = 2 THEN 'PAGE'
    ELSE 'ERROR'
  END Compression_Type,
  CASE
    WHEN x.type_desc = 'CLUSTERED' THEN 'ALTER TABLE [' + o.name + '] REBUILD WITH (DATA_COMPRESSION = NONE)'
    WHEN x.type_desc = 'NONCLUSTERED' THEN 'ALTER INDEX [' + x.name + '] ON [' + o.name + '] REBUILD WITH (DATA_COMPRESSION = NONE)'
    ELSE '--'
  END [TSQL (Undo Compression)]
FROM sys.partitions p    JOIN sys.objects o ON p.object_id = o.object_id
    JOIN sys.indexes x ON x.object_id = p.object_id AND x.index_id = p.index_id
    JOIN sys.sysindexes i ON o.object_id = i.id AND p.index_id = i.indid
    AND p.data_compression in (1,2)
ORDER BY o.name, p.data_compression, p.index_id
GO