/* ***********************************************************
   Antes de configurar la programación de consulta revisar los 
   tres comentarios que existen en la consulta:
   - Indicar BBDD a monitorizar
   - Indicar TIEMPO de inactividad de los usarios
   - Indicar ACCION a realizar
************************************************************ */

/* Cambiar MiBBDDNav por el nombre real de la BBDD */
USE MiBBDDNav

DECLARE @TiempoInactividad INT;
DECLARE @ProcessId INT;
DECLARE @ListofIDs TABLE(IDs VARCHAR(100), ID INT IDENTITY(1,1));

/* Configurar el tiempo de actividad, definido en milisengundos 60000 = 1 minuto	*/
SET @TiempoInactividad = 60000; 

INSERT INTO @ListofIDs SELECT [Connection ID] FROM [Session] 
WHERE [Application Name] = 'Microsoft Dynamics NAV Classic client' AND [Idle Time] > @TiempoInactividad;

DECLARE [cursorProcess] CURSOR FOR SELECT IDs FROM @ListofIDs;
OPEN [cursorProcess];
FETCH NEXT FROM [cursorProcess] INTO @ProcessId;
WHILE @@FETCH_STATUS = 0 BEGIN
	/* Elegir solamente una acción a ejecutar: Eliminar sesión (KILL) / Mostrar sesión (PRINT) */
	--EXEC('KILL ' + @ProcessId)
	PRINT @ProcessId;
	FETCH NEXT FROM [cursorProcess] INTO @ProcessId;
END 

CLOSE [cursorProcess];
DEALLOCATE [cursorProcess];  
