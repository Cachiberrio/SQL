/* This script creates the necessary functions to run the
   system procedure sp_estimate_data_compression_savings,
   and then creates a copy of the procedure which it calls
   usp_estimate_data_compression_savings.
   It is intended for use on Azure SQL DB that does not
   by default contain all the necessary functions that the
   procedure needs.

   In addition, the official procedure has an explicit test
   for Engine Edition, that will reject an Azure SQL DB,
   and that test has been commented out.

   CREATED BY Kalen Delaney, June 6, 2018

*/


CREATE OR ALTER FUNCTION fn_generate_type
(
        @type_id                int,
        @type_name              sysname,
        @max_length             smallint,
        @precision              tinyint,
        @scale                  tinyint,
        @collation_name         sysname,
        @is_xml_document        bit,
        @xml_collection_id      int
)
RETURNS nvarchar(max)
AS
BEGIN
        RETURN
        CASE
                WHEN @type_id in (41, 42, 43) -- new date time types
                        THEN quotename(@type_name) + '(' + convert(nvarchar(10), @scale) + ')'
                WHEN @type_id in (106, 108) -- fixed point numbers
                        THEN quotename(@type_name) + '(' + convert(nvarchar(10), @precision) + ',' + convert(nvarchar(10), @scale) + ')'
                WHEN @type_id in (62) -- floating point numbers WHERE width can be specified
                        THEN quotename(@type_name) + '(' + convert(nvarchar(10), @precision) + ')'
                WHEN @type_id = 173 -- binary
                        THEN quotename(@type_name) + '(' + convert(nvarchar(10), @max_length) + ')'
                WHEN @type_id = 165 -- varbinary
                        THEN quotename(@type_name) + '(' + CASE @max_length WHEN -1 THEN 'max' ELSE convert(nvarchar(10), @max_length) END + ')'
                WHEN @type_id in (167, 175) -- ascii char
                        THEN quotename(@type_name) + '(' + CASE @max_length WHEN -1 THEN 'max' ELSE convert(nvarchar(10), @max_length) END + ') COLLATE ' + @collation_name
                WHEN @type_id in (231, 239) -- unicode char
                        THEN quotename(@type_name) + '(' + CASE @max_length WHEN -1 THEN 'max' ELSE convert(nvarchar(10), @max_length / 2) END + ') COLLATE ' + @collation_name
                WHEN @type_id = 241                     -- xml
                        THEN quotename(@type_name) +
                        case
                                WHEN @xml_collection_id <> 0
                                        THEN '(' + CASE WHEN @is_xml_document = 1 THEN 'document ' ELSE '' END +
                                                quotename('schema_' + convert(nvarchar(10), @xml_collection_id)) + ')'
                                ELSE ''
                        END
                ELSE quotename(@type_name)
        END
END;   /* fn_generate_type */
GO
---------------------------------------------

CREATE OR ALTER FUNCTION fn_column_definition
(
        @column_name            sysname,
        @system_type_id         int,
        @system_type_name       sysname,
        @max_length                     smallint,
        @precision                      tinyint,
        @scale                          tinyint,
        @collation_name         sysname,
        @is_nullable            bit,
        @is_xml_document        bit,
        @xml_collection_id      int,
        @is_user_defined        bit,
        @is_assembly_type       bit,
        @is_fixed_length        bit
)
RETURNs nvarchar(max)
BEGIN
        DECLARE @column_def nvarchar(max)
        -- SET column name and type
        SET @column_def = quotename(@column_name) + ' ' +
                CASE
                WHEN @is_assembly_type = 1      -- convert assembly to varbinary
                        THEN CASE WHEN @is_fixed_length = 1 THEN '[binary]' ELSE '[varbinary]' END +
                        '(' + CASE WHEN @max_length = -1 THEN 'max' ELSE convert(nvarchar(10), @max_length) END + ')'
                ELSE   -- what if we we have a user defined type? (like alias)
                        dbo.fn_generate_type(@system_type_id, @system_type_name, @max_length, @precision,
                                                   @scale, @collation_name, @is_xml_document, @xml_collection_id)
                END

        -- Handle nullability
        SET @column_def = @column_def + CASE @is_nullable WHEN 1 THEN ' NULL' ELSE ' NOT NULL' END;

        RETURN @column_def
END; /* fn_column_definition */
GO
---------------------------------

CREATE OR ALTER FUNCTION fn_generate_index_ddl
(
        @object_id int,
        @index_id int,
        @current_compression int,
        @sample_table sysname,
        @index_name sysname,
        @desired_compression int
)
RETURNs @ddl_statements table(create_index_ddl nvarchar(max), compress_current_ddl nvarchar(max), compress_desired_ddl nvarchar(max), is_primary bit)
as
BEGIN
        /*      There are four cases for indexes
                        1) Heap
                                Do not perform additional DDL to create index
                                Use ALTER TABLE DDL to compress table
                        2) Primary Key
                                Use ALTER TABLE DDL to add primary key constraint
                                USE ALTER INDEX DDL to comrpess index
                        3) Non-PK
                                Use CREATE INDEX DDL to create index
                                USE ALTER INDEX DDL to compress index
                        4) XML Index
                                This should have been filtered out before we got here
                In all cases, if the index is non-clustered, drop the index */

        DECLARE @create_index_ddl               nvarchar(max) = NULL;
        DECLARE @compress_current_ddl   nvarchar(max) = NULL;
        DECLARE @compress_desired_ddl   nvarchar(max) = '';

        IF @index_id = 0                -- HEAP
        BEGIN
                -- Compress the table using the current compression scheme
                IF @current_compression <> 0
                BEGIN
                        SET @compress_current_ddl = 'ALTER TABLE ' + quotename(@sample_table) + ' rebuild with(data_compression = '
                                                  + CASE @current_compression WHEN 1 THEN 'row' ELSE 'page' END + ');';
                END

                -- Compress the table to desired compression scheme
                SET @compress_desired_ddl = 'ALTER TABLE ' + quotename(@sample_table) + ' rebuild with (data_compression = '
                                          + CASE @desired_compression WHEN 0 THEN 'none' WHEN 1 THEN 'row' ELSE 'page' END + ');';
        END
        ELSE
        BEGIN
                -- Get Index parameters
                DECLARE @is_unique bit, @ignore_dup_key bit, @is_primary bit, @fill_factor tinyint, @is_padded bit;
                DECLARE @filter_def nvarchar(max);
                SELECT @is_unique = i.is_unique, @ignore_dup_key = i.ignore_dup_key, @is_primary = i.is_primary_key,
               @fill_factor = i.fill_factor, @is_padded = i.is_padded, @filter_def = i.filter_definition
                FROM sys.indexes i with (nolock)
                WHERE i.object_id = @object_id and i.index_id = @index_id;

                -- key columns
                DECLARE @key_columns nvarchar(max);
                SET @key_columns  = stuff(
                        (SELECT ', ' + quotename(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' desc' ELSE ' asc' end as [text()]
                        FROM sys.index_columns ic with (nolock) JOIN sys.columns c with (nolock) on ic.object_id = c.object_id and ic.column_id = c.column_id
                        WHERE ic.object_id = @object_id and ic.index_id = @index_id and ic.is_included_column = 0 and ic.key_ordinal <> 0
                        ORDER BY ic.key_ordinal
                        for xml path('')), 1, 2, '');

                -- included columns
                DECLARE @include_columns nvarchar(max);
                SET @include_columns = stuff(
                        (SELECT ', ' + quotename(c.name) as [text()]
                        FROM sys.index_columns ic with (nolock) JOIN sys.columns c with (nolock) on ic.object_id = c.object_id and ic.column_id = c.column_id
                        WHERE ic.object_id = @object_id and ic.index_id = @index_id and ic.is_included_column = 1
                        ORDER BY ic.index_column_id
                        for xml path('')), 1, 2, '');

                -- partition columns -- only those that are not already included in either of the two above
                -- For non-unique, clustered index, partition columns are part of the key
                -- For non-unique, nonclustered indexes, partition columns can be included
                IF (@is_unique = 0)
                BEGIN
                        DECLARE @partition_column nvarchar(max);

                        SELECT @partition_column = quotename(c.name)
                        FROM sys.index_columns ic with (nolock) JOIN sys.columns c with (nolock) on ic.object_id = c.object_id and ic.column_id = c.column_id
                        WHERE ic.object_id = @object_id and ic.index_id = @index_id and ic.is_included_column = 0
                        and ic.key_ordinal = 0 and ic.partition_ordinal = 1

                        IF (@partition_column is not null)
                        BEGIN
                                IF (@index_id = 1) -- clustered index
                                        SET @key_columns = coalesce(@key_columns + ', ' + @partition_column, @partition_column);
                                ELSE    --nonclustered index
                                        SET @include_columns = coalesce(@include_columns + ', ' + @partition_column, @partition_column);
                        END
                END;

                -- For a clustered index, we will use a different name so that the index stays around until the sample table is dropped
                IF (@index_id = 1)
                BEGIN
                        SET @index_name = @index_name + '_clustered';
                END

                IF (@is_primary = 1)
                BEGIN
                        SET @index_name = @index_name + '_pk';
                END

                IF @is_primary = 1
                BEGIN
                        -- for a primary key we don't have to worry about included or partition columns
                        SET @create_index_ddl = 'ALTER TABLE ' + quotename(@sample_table) + ' add constraint ' + quotename(@index_name) + ' primary key ' +
                        CASE WHEN @index_id = 1 THEN 'clustered (' ELSE 'nonclustered (' END + @key_columns + ')';
                END
                ELSE
                BEGIN
                        SET @create_index_ddl = 'create' + CASE WHEN @is_unique = 1 THEN ' unique' ELSE '' END +
                        CASE WHEN @index_id = 1 THEN ' clustered' ELSE ' nonclustered' END + ' index ' + quotename(@index_name) +
                        ' on ' + quotename(@sample_table) + '(' + @key_columns + ')';

                        IF (@include_columns is not null)
                                SET @create_index_ddl = @create_index_ddl + ' include (' + @include_columns + ')';

                        IF (@filter_def is not null)
                                SET @create_index_ddl = @create_index_ddl + ' WHERE ' + @filter_def;
                END;

                -- Append Index Options
                IF (@ignore_dup_key = 1 or @fill_factor <> 0 or @is_padded = 1)
                BEGIN
                        SET @create_index_ddl = @create_index_ddl + ' with (';

                        DECLARE @requires_comma bit = 0;

                        IF @ignore_dup_key = 1
                        BEGIN
                                SET @create_index_ddl = @create_index_ddl + 'ignore_dup_key = on';
                                SET @requires_comma = 1;
                        END;

                        IF @fill_factor <> 0
                        BEGIN
                                IF @requires_comma = 1 SET @create_index_ddl = @create_index_ddl + ', ';
                                SET @create_index_ddl = @create_index_ddl + 'fillfactor = ' + convert(nvarchar(3), @fill_factor);
                                SET @requires_comma = 1;
                        END;

                        IF @is_padded = 1
                        BEGIN
                                IF @requires_comma = 1 SET @create_index_ddl = @create_index_ddl + ', ';
                                SET @create_index_ddl = @create_index_ddl + 'pad_index = on';
                        END;

                        SET @create_index_ddl = @create_index_ddl + ')';
                END;

                -- Compress the index with current compression
                IF @current_compression <> 0
                BEGIN
                        IF (@index_id = 1 or @is_primary = 1)
                                SET @compress_current_ddl = 'ALTER TABLE ' + quotename(@sample_table) + ' rebuild with(data_compression = ' +
                                        CASE @current_compression WHEN 1 THEN 'row' ELSE 'page' END + ');';
                        ELSE
                                SET @compress_current_ddl = 'alter index ' + quotename(@index_name) + ' on ' + quotename(@sample_table) +
                                        ' rebuild with(data_compression = ' +
                                        CASE @current_compression WHEN 1 THEN 'row' ELSE 'page' END + ');';
                END;

                -- Compress the index with desired compression scheme
                IF (@index_id = 1  or @is_primary = 1)
                        SET @compress_desired_ddl  = 'ALTER TABLE ' + quotename(@sample_table) + + ' rebuild with(data_compression = ' +
                                CASE @desired_compression WHEN 0 THEN 'none' WHEN 1 THEN 'row' ELSE 'page' END + ');';
                ELSE
                        SET @compress_desired_ddl = 'alter index ' + quotename(@index_name) + ' on ' + quotename(@sample_table) +
                                ' rebuild with (data_compression = ' + CASE @desired_compression WHEN 0 THEN 'none' WHEN 1 THEN 'row' ELSE 'page' END + ');';
        END;

        INSERT INTO @ddl_statements values (@create_index_ddl, @compress_current_ddl, @compress_desired_ddl, @is_primary);

        RETURN;
END; /* fn_generate_index_ddl */
GO
--------------------------------------------------

CREATE OR ALTER FUNCTION fn_generate_table_sample_ddl(
        @object_id int,
        @schema sysname,
        @table sysname,
        @partition_number int,
        @partition_column_id int,
        @partition_function_id int,
        @sample_table_name sysname,
        @dummy_column sysname,
        @include_computed bit,
        @sample_percent float
)
RETURNs @ddl_statements table(alter_ddl nvarchar(max), insert_ddl nvarchar(max), table_option_ddl nvarchar(max))
as
BEGIN
        -- Generate column defintions and SELECT lists
        DECLARE @column_definitions nvarchar(max);
        DECLARE @into_list nvarchar(max);
        DECLARE @columns nvarchar(max);

        with columns_cte as
        (
                SELECT c.column_id, c.name, c.system_type_id, st.name as system_type_name, c.max_length, c.precision, c.scale, c.collation_name,
                   c.is_nullable, c.is_xml_document, c.xml_collection_id, ut.is_user_defined, ut.is_assembly_type, at.is_fixed_length
                FROM sys.columns c with (nolock)
                LEFT JOIN sys.computed_columns cc with (nolock) on c.object_id = cc.object_id and c.column_id = cc.column_id
                JOIN sys.types ut with (nolock) on c.user_type_id = ut.user_type_id
                LEFT JOIN sys.types st with (nolock) on c.system_type_id = st.user_type_id
                LEFT JOIN sys.assembly_types at with (nolock) on c.user_type_id = at.user_type_id
                WHERE c.object_id = @object_id
                  and 1 = CASE @include_computed WHEN 0 THEN coalesce(cc.is_persisted, 1) ELSE 1 END
        )
        SELECT
                @column_definitions = (
                        SELECT ', ' + dbo.fn_column_definition(name, system_type_id, system_type_name, max_length, precision, scale,
                                        collation_name, is_nullable, is_xml_document, xml_collection_id, is_user_defined, is_assembly_type, is_fixed_length) as [text()]
                        FROM columns_cte
                        ORDER BY column_id for xml path(''), type).value('.', 'nvarchar(max)'),
                @into_list = (
                        SELECT ', ' + quotename(name)
                        FROM columns_cte WHERE system_type_id <> 189 -- exclude timestamp columns
                        ORDER BY column_id for xml path(''), type).value('.', 'nvarchar(max)'),
                @columns = (
                        SELECT ', ' +
                                CASE
                                WHEN xml_collection_id <> 0 THEN -- untyped the xml and then it will be retyped again
                                        'convert(xml, ' + quotename(name) + ')'
                                WHEN is_assembly_type = 1 THEN
                                        'convert(varbinary(8000), ' + quotename(name) + ')'
                                ELSE quotename(name) END
                                as [text()]
                        FROM columns_cte WHERE system_type_id <> 189 -- exclude timestamp columns
                        ORDER BY column_id for xml path(''), type).value('.', 'nvarchar(max)')

        -- Remove the extra , FROM the BEGINning
        SET @column_definitions = stuff(@column_definitions, 1, 2, '');
        SET @into_list = stuff(@into_list, 1, 2, '');
        SET @columns = stuff(@columns, 1, 2, '');

        -- Generate ALTER ddl statements
        DECLARE @alter_ddl nvarchar(max) = ''
        SET @alter_ddl = 'ALTER TABLE ' + quotename(@sample_table_name) + ' add ' + @column_definitions + '; '
        SET @alter_ddl = @alter_ddl + 'ALTER TABLE ' + quotename(@sample_table_name) + ' drop column ' + quotename(@dummy_column) + ';'

        -- generate insert ... SELECT statement
        DECLARE @ddl nvarchar(max) = 'INSERT INTO ' + quotename(@sample_table_name) + '(' + @into_list + ')' + ' SELECT ' + @columns +
                                                                ' FROM ' + quotename(@schema) + '.' + quotename(@table) + ' tablesample (' + convert(nvarchar(max), @sample_percent) + ' percent)';

        IF ('V' = (SELECT type FROM sys.objects WHERE object_id = @object_id))
        BEGIN
                SET @ddl = @ddl + ' with (noexpand)'
        END

        -- add predicate to filter on partition
        IF @partition_column_id is not null and @partition_function_id is not null
        BEGIN
                DECLARE @part_func_name sysname = (SELECT quotename(pf.name) FROM sys.partition_functions as pf with (nolock) WHERE pf.function_id = @partition_function_id);
                DECLARE @part_column sysname = (SELECT quotename(name) FROM sys.columns with (nolock) WHERE object_id = @object_id and column_id = @partition_column_id);

                SET @ddl = @ddl + ' WHERE $PARTITION.' + @part_func_name + '(' + @part_column + ') = ' + convert(nvarchar(10), @partition_number)
;

        END

        DECLARE @table_option_ddl nvarchar(max) = null;
        IF ('U' = (SELECT type FROM sys.objects WHERE object_id = @object_id))
        BEGIN
                DECLARE @text_in_row_limit int;
                DECLARE @large_value_types_out_of_row bit;

                SELECT @text_in_row_limit = text_in_row_limit, @large_value_types_out_of_row = large_value_types_out_of_row
                FROM sys.tables
                WHERE object_id = @object_id;

                --The 'text_in_row' parameter for sp_tableoption only applies to text, ntext, and image types.  Without one of
                --these types, a transaction abort error will be thrown and will cause a deadlock, so we avoid the deadlock here.
                DECLARE @use_text_in_row as bit;
                SET @use_text_in_row = 0;
                IF (@text_in_row_limit <> 0)
                BEGIN
                        SET @use_text_in_row =
                                (SELECT count(*) --any non zero value converts bit type to 1
                                FROM sys.systypes as types
                                INNER JOIN (SELECT cols.xtype as xtype FROM sys.syscolumns as cols INNER JOIN sys.sysobjects as objs on cols.id = objs.id WHERE objs.id = @object_id) as coltypes
                                on coltypes.xtype = types.xtype
                                WHERE types.name = 'ntext' or types.name = 'text' or types.name = 'image');
                END

                IF (@use_text_in_row <> 0 or @large_value_types_out_of_row <> 0)
                BEGIN
                        SET @table_option_ddl = 'use tempdb; ';
                        IF (@text_in_row_limit <> 0)
                        BEGIN
                                SET @table_option_ddl = @table_option_ddl + 'EXEC sp_tableoption ''' + quotename(@sample_table_name) + ''', ''text in row'', ''' + convert(nvarchar(max), @text_in_row_limit) + ''';';
                        END

                        IF (@large_value_types_out_of_row <> 0)
                        BEGIN
                                SET @table_option_ddl = @table_option_ddl + 'EXEC sp_tableoption ''' + quotename(@sample_table_name) + ''', ''large value types out of row'', ''1'';';
                        END
                END
        END

        INSERT INTO @ddl_statements values (@alter_ddl, @ddl, @table_option_ddl);

        RETURN;
END; /* fn_generate_table_sample_ddl */
GO
-----------------------------------

CREATE OR ALTER PROCEDURE usp_estimate_data_compression_savings
	@schema_name		sysname,
	@object_name		sysname,

	@index_id		int,
	@partition_number	int,
	@data_compression	nvarchar(60)
as
BEGIN
	SET nocount on;

	--IF (SERVERPROPERTY ('EngineEdition') NOT IN (2 /* Standard */, 3 /* Enterprise */, 4 /* Express */))
	--BEGIN
	--	DECLARE @procName sysname = N'sp_estimate_data_compression_savings';
	--	DECLARE @procNameLen int = datalength(@procName);

	--	DECLARE @instanceName sysname = ISNULL(CONVERT(sysname, SERVERPROPERTY('InstanceName')), N'MSSQLSERVER');
	--	DECLARE @instanceNameLen int = datalength(@instanceName);

	--	RAISERROR(534, -1, -1, @procNameLen, @procName, @instanceNameLen, @instanceName);
	--	RETURN @@error;
	--END

	-- Check @schema_name parameter
	DECLARE @schema_id int
	IF (@schema_name is null)
		SET @schema_id = schema_id()
	ELSE
		SET @schema_id = schema_id(@schema_name)

	IF (@schema_id is null)
	BEGIN
		RAISERROR(15659, -1, -1, @schema_name);
		RETURN @@error;
	END
	-- SET the schema name to the default schema
	IF (@schema_name is null)
		SET @schema_name = schema_name(@schema_id);

	-- check object name
	IF (@object_name is null)
	BEGIN
		RAISERROR(15223, -1, -1, 'object_name');
		RETURN @@error;
	END

	-- Check if the object name is a temporary table
	IF (substring(@object_name, 1, 1) = '#')
	BEGIN
		RAISERROR(15661, -1, -1);
		RETURN @@error;
	END

	-- Verify that the object exists and that the user has permission to see it.
	DECLARE @object_id int = object_id(quotename(@schema_name) + '.' + quotename(@object_name));
	DECLARE @object_len int;
	IF (@object_id is null)
	BEGIN
		SET @object_len = datalength(@object_name);
		RAISERROR(1088, -1, -1, @object_len, @object_name);
		RETURN @@error;
	END

	-- Check object type. Must be user table or view.
	IF (NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = @object_id and (type = 'U' or type = 'V')))
	BEGIN
		RAISERROR(15001, -1, -1, @object_name);
		RETURN @@error;
	END

	-- Check SELECT permission on table. The check above fails if the user has no permissions
	-- on the table, so this check applies only if the user has some permission other than
	-- SELECT (e.g., INSERT) but not SELECT itself.
	IF has_perms_by_name(quotename(@schema_name) + '.' + quotename(@object_name), 'object', 'SELECT') = 0
	BEGIN
		DECLARE @db_name sysname = db_name();
		DECLARE @db_len int = datalength(@db_name), @schema_len int = datalength(@schema_name);
		SET @object_len = datalength(@object_name);
		RAISERROR(229, -1, -1, N'SELECT', @object_len, @object_name, @db_len, @db_name, @schema_len, @schema_name);
		RETURN @@error;
	END

	-- Check for sparse columns or column sets.
	DECLARE @sparse_columns_and_column_sets int = (SELECT count(*) FROM sys.columns WHERE object_id = @object_id and (is_sparse = 1 or is_column_SET = 1));
	IF (@sparse_columns_and_column_sets > 0)
	BEGIN
		RAISERROR(15662, -1, -1);
		RETURN @@error;
	END

	-- check data compression
	IF (@data_compression is null)
	BEGIN
		RAISERROR(15223, -1, -1, 'datacompression');
		RETURN @@error;
	END

	SET @data_compression = upper(@data_compression);
	IF (@data_compression not in ('NONE', 'ROW', 'PAGE'))
	BEGIN
		RAISERROR(3217, -1, -1, 'datacompression');
		RETURN @@error;
	END

	IF (@index_id is not null)
	BEGIN
		DECLARE @index_type int = null;
		SELECT @index_type = type FROM sys.indexes with (nolock) WHERE object_id = @object_id and index_id = @index_id;

		IF (@index_type is null)
		BEGIN
			RAISERROR(15323, -1, -1, @object_name);
			RETURN @@error;
		END

		IF (@index_type not in (0, 1, 2))
		BEGIN
			-- Currently do not support XML, spatial, columnstore, and hash indexes
			RAISERROR(15660, -1, -1);
			RETURN @@error;
		END
	END

	DECLARE @desired_compression int = CASE @data_compression WHEN 'NONE' THEN 0 WHEN 'ROW' THEN 1 ELSE 2 END;

	-- Hard coded sample table and indexes that we will use
	DECLARE @sample_table nvarchar(256) = '#sample_tableDBA05385A6FF40F888204D05C7D56D2B';
	DECLARE @dummy_column nvarchar(256) = 'dummyDBA05385A6FF40F888204D05C7D56D2B';
	DECLARE @sample_index nvarchar(256) = 'sample_indexDBA05385A6FF40F888204D05C7D56D2B';
	DECLARE @pages_to_sample int = 5000;

	---- Find all the partitions and their partitioning info that we need
	SELECT i.index_id, p.partition_number, p.data_compression, p.data_compression_desc, ic.column_id as [partition_column_id],
		   f.function_id as [partition_function_id],
		   CASE WHEN EXISTS  (SELECT * FROM sys.computed_columns c with (nolock) JOIN sys.index_columns ic with (nolock)
								  ON ic.object_id = c.object_id and ic.column_id = c.column_id and c.is_persisted = 0
							   WHERE ic.index_id = i.index_id) THEN 1 ELSE 0 END as requires_computed,
		   create_index_ddl, compress_current_ddl, compress_desired_ddl, is_primary
	INTO #index_partition_info
	FROM sys.partitions p with (nolock)
	JOIN sys.indexes i with (nolock) on p.object_id = i.object_id and p.index_id = i.index_id
	LEFT JOIN (SELECT * FROM sys.index_columns with (nolock) WHERE partition_ordinal = 1) ic on p.object_id = ic.object_id and i.index_id = ic.index_id
	LEFT JOIN sys.partition_schemes ps with (nolock) on ps.data_space_id = i.data_space_id
	LEFT JOIN sys.partition_functions f with (nolock) on f.function_id = ps.function_id
	CROSS APPLY fn_generate_index_ddl(@object_id, i.index_id, p.data_compression, @sample_table, @sample_index, @desired_compression)
	WHERE p.object_id = @object_id
	  and i.is_disabled = 0 and i.is_hypothetical = 0
	  -- Filter on index and/or partition if these were provided - always include the clustered index if there is one
	  and i.type <= 2 -- ignore XML, Extended, columnstore indexes for now
	  and (i.index_id = CASE WHEN @index_id is null THEN i.index_id ELSE @index_id END or i.index_id = 1)
	  and p.partition_number = CASE WHEN @partition_number is null THEN p.partition_number ELSE @partition_number END
	ORDER BY i.index_id

	-- If the user requested to estimate compression of a view that isn't indexed, we will not have anything in #index_partition_info
	if (0 = (SELECT count(*) FROM #index_partition_info))
	BEGIN
		RAISERROR(15001, -1, -1, @object_name);
		RETURN @@error;
	END

	-- Find all the xml schema collections used by the table
	SELECT	'use tempdb; create xml schema collection ' + quotename(N'schema_' + convert(nvarchar(10), xml_collection_id)) +
		' as N''' + replace(convert(nvarchar(max), xml_schema_namespace(schema_name, name)), N'''', N'''''') + '''' as create_ddl,
		'use tempdb; drop xml schema collection ' + quotename(N'schema_' + convert(nvarchar(10), xml_collection_id)) as drop_ddl
	INTO #xml_schema_ddl
	FROM
	(
		SELECT distinct c.xml_collection_id, xsc.name, s.name as schema_name
		FROM sys.columns c with (nolock)
		JOIN sys.xml_schema_collections xsc with (nolock) on c.xml_collection_id = xsc.xml_collection_id
		JOIN sys.schemas s with (nolock) on xsc.schema_id = s.schema_id
		WHERE c.object_id = @object_id and c.xml_collection_id <> 0
	) t

	-- create required xml schema collections
	DECLARE c cursor local fast_forward for SELECT create_ddl FROM #xml_schema_ddl
	OPEN c;
	DECLARE @create_ddl nvarchar(max)
	FETCH NEXT FROM c INTO @create_ddl;
	WHILE @@fetch_status = 0
	BEGIN
		EXEC(@create_ddl);

		FETCH NEXT FROM c INTO @create_ddl;
	END;
	CLOSE c;
	DEALLOCATE c;

	-- Create results table
	CREATE TABLE #estimated_results ([object_name] sysname, [schema_name] sysname, [index_id] int, [partition_number] int,
									[size_with_current_compression_setting(KB)] bigint, [size_with_requested_compression_setting(KB)] bigint,
									[sample_size_with_current_compression_setting(KB)] bigint, [sample_size_with_requested_compression_setting(KB)] bigint);

	-- Outer Loop - Iterate through each unique partition sample
	-- Iteration does not have to be in any particular order, the results table will sort that out
	DECLARE c cursor local fast_forward for
		SELECT partition_column_id, partition_function_id, partition_number, requires_computed, alter_ddl, insert_ddl, table_option_ddl
		FROM (SELECT distinct partition_column_id, partition_function_id, partition_number, requires_computed FROM #index_partition_info ) t
		CROSS APPLY (SELECT CASE WHEN used_page_count <= @pages_to_sample THEN 100 ELSE 100. * @pages_to_sample / used_page_count END as sample_percent
					 FROM sys.dm_db_partition_stats ps WHERE ps.object_id = @object_id and index_id < 2 and ps.partition_number = t.partition_number) ps
		CROSS APPLY
		fn_generate_table_sample_ddl(
			@object_id, @schema_name, @object_name, partition_number, partition_column_id, partition_function_id,
			@sample_table, @dummy_column, requires_computed, sample_percent)
	OPEN c;

	DECLARE @curr_partition_column_id int, @curr_partition_function_id int, @curr_partition_number int,
            @requires_computed bit, @alter_ddl nvarchar(max), @insert_ddl nvarchar(max), @table_option_ddl nvarchar(max);
	FETCH NEXT FROM c INTO @curr_partition_column_id, @curr_partition_function_id, @curr_partition_number,
						   @requires_computed, @alter_ddl, @insert_ddl, @table_option_ddl;
	WHILE @@fetch_status = 0
	BEGIN
		-- Step 1. Create the sample table in current scope
		CREATE TABLE [#sample_tableDBA05385A6FF40F888204D05C7D56D2B]([dummyDBA05385A6FF40F888204D05C7D56D2B] [int]);

		-- Step 2. Sample the table
		EXEC (@alter_ddl);

		ALTER TABLE [#sample_tableDBA05385A6FF40F888204D05C7D56D2B] rebuild

		EXEC (@table_option_ddl);

		EXEC (@insert_ddl);

		/*	Step 3.   Loop through the indexes that use this sampled partition */
		DECLARE index_partition_cursor cursor local fast_forward for
			SELECT ipi.index_id, ipi.data_compression, ipi.create_index_ddl, ipi.compress_current_ddl, ipi.compress_desired_ddl, ipi.is_primary
			FROM #index_partition_info ipi
			WHERE (ipi.partition_column_id = @curr_partition_column_id or (ipi.partition_column_id is null and @curr_partition_column_id is null))
			  and (partition_function_id = @curr_partition_function_id or (partition_function_id is null and @curr_partition_function_id is null))
			  and (ipi.partition_number = @curr_partition_number or (ipi.partition_number is null and @curr_partition_number is null))
			  and ipi.requires_computed = @requires_computed
		OPEN index_partition_cursor;

		DECLARE @sample_table_object_id int = object_id('tempdb.dbo.#sample_tableDBA05385A6FF40F888204D05C7D56D2B');

		DECLARE @curr_index_id int, @cur_data_compression int, @create_index_ddl nvarchar(max), @compress_current_ddl nvarchar(max), @compress_desired_ddl nvarchar(max), @is_primary bit;
		FETCH NEXT FROM index_partition_cursor INTO @curr_index_id, @cur_data_compression, @create_index_ddl, @compress_current_ddl, @compress_desired_ddl, @is_primary;
		WHILE @@fetch_status = 0
		BEGIN
			DECLARE @current_size bigint, @sample_compressed_current bigint, @sample_compressed_desired bigint;

			-- Get Partition's current size
			SET @current_size =
				(SELECT used_page_count
				 FROM sys.dm_db_partition_stats
				 WHERE object_id = @object_id and index_id = @curr_index_id
				 and partition_number = @curr_partition_number);

			-- Create the index
			IF @create_index_ddl is not null
			BEGIN
				EXEC (@create_index_ddl);
			END;

			DECLARE @sample_index_id int = CASE
					WHEN @curr_index_id = 0 THEN 0 -- heap
					WHEN @curr_index_id = 1 THEN 1 -- cluster
					ELSE
					(SELECT index_id FROM tempdb.sys.indexes with (nolock)
					WHERE object_id = @sample_table_object_id and index_id <> 0 and index_id <> 1)
					-- In all other cases, there should only be one index
					END;

			-- Compress to current compression level
			IF @compress_current_ddl is not null
			BEGIN
				EXEC (@compress_current_ddl);
			END;

			-- Get sample's size at current compression level
			SELECT @sample_compressed_current = used_page_count
			FROM tempdb.sys.dm_db_partition_stats
			WHERE object_id = @sample_table_object_id and index_id = @sample_index_id;

			-- Compress to target level
			IF (@index_id is null or @curr_index_id = @index_id)
			BEGIN
			EXEC (@compress_desired_ddl);
			END

			-- Get sample's size at desired compression level
			SELECT @sample_compressed_desired = used_page_count
			FROM tempdb.sys.dm_db_partition_stats
			WHERE object_id = @sample_table_object_id and index_id = @sample_index_id;

			-- Drop non-clustered and non-primary key indexes (this is based on name - pk has special name since it can be non-clustered)
			-- #tables can get created FROM either a contained db or a podb. In contained db context, the index names are mangled by adding #&$, so we have an additional LIKE clause to find such index names
			IF (EXISTS(SELECT * FROM tempdb.sys.indexes with (nolock) WHERE name = 'sample_indexDBA05385A6FF40F888204D05C7D56D2B' OR name like 'sample_indexDBA05385A6FF40F888204D05C7D56D2B#&$%'
						and object_id = @sample_table_object_id))
			BEGIN
				drop index [sample_indexDBA05385A6FF40F888204D05C7D56D2B] on [#sample_tableDBA05385A6FF40F888204D05C7D56D2B];
			END
			ELSE
			BEGIN
				-- For a non-clustered primary key, drop the constraint to drop the index
				IF (@is_primary = 1 and @sample_index_id <> 1)
				BEGIN
					ALTER TABLE [#sample_tableDBA05385A6FF40F888204D05C7D56D2B] drop constraint [sample_indexDBA05385A6FF40F888204D05C7D56D2B_pk];
				END
			END

			-- if the current setting and requested setting are the same, show how much we would save if we discount fragmentation and new
			-- compression schemes (like unicode compression). In these cases, we use the sample size or the current size of the table as
			-- starting point, instead of the temp table that was created
			--
			IF (@cur_data_compression = @desired_compression)
			BEGIN
				IF (@current_size > @pages_to_sample)
				BEGIN
					SET @sample_compressed_current = @pages_to_sample
				END
				ELSE
				BEGIN
					SET @sample_compressed_current = @current_size
				END
			END

			DECLARE @estimated_compressed_size bigint =
			CASE @sample_compressed_current
			WHEN 0 THEN 0
			ELSE @current_size * ((1. * cast (@sample_compressed_desired as float)) / @sample_compressed_current)
			END;

			IF (@index_id is null or @curr_index_id = @index_id)
			BEGIN
			INSERT INTO #estimated_results values (@object_name, @schema_name, @curr_index_id, @curr_partition_number,
					@current_size * 8, @estimated_compressed_size * 8, @sample_compressed_current * 8, @sample_compressed_desired * 8);
			END

			FETCH NEXT FROM index_partition_cursor INTO @curr_index_id, @cur_data_compression, @create_index_ddl, @compress_current_ddl, @compress_desired_ddl, @is_primary;
		END;
		CLOSE index_partition_cursor;
		DEALLOCATE index_partition_cursor;

		-- Step 4. Drop the sample table
		DROP TABLE [#sample_tableDBA05385A6FF40F888204D05C7D56D2B];

		FETCH NEXT FROM c INTO @curr_partition_column_id, @curr_partition_function_id, @curr_partition_number,
							   @requires_computed, @alter_ddl, @insert_ddl, @table_option_ddl;
	END
	CLOSE c;
	DEALLOCATE c;

	-- drop xml schema collection
	DECLARE c cursor local fast_forward for SELECT drop_ddl FROM #xml_schema_ddl
	OPEN c;
	DECLARE @drop_ddl nvarchar(max)
	FETCH NEXT FROM c INTO @drop_ddl;
	WHILE @@fetch_status = 0
	BEGIN
		EXEC(@drop_ddl);

		FETCH NEXT FROM c INTO @drop_ddl;
	END;
	CLOSE c;
	DEALLOCATE c;

	SELECT * FROM #estimated_results;

	DROP TABLE #estimated_results;
	DROP TABLE #xml_schema_ddl;
END;/* usp_estimate_data_compression_savings */
GO



