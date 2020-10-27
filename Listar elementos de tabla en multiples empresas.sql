USE [NAV2009R2]
/* Declaraci�n de varibles */
DECLARE @ListofCompanys TABLE(Name VARCHAR(100), ID INT IDENTITY(1,1));		-- Tabla para almacenar la lista de compa�ias existentes en la bbdd
DECLARE @Company VARCHAR(300);												-- Variable para almacenar cada una de las compa�ias
DECLARE @Query VARCHAR(1024);												-- Variable para almacenar la consulta generada
/* Obtener todas las empresas existentes */
INSERT INTO @ListofCompanys SELECT REPLACE(Name,'.','_') FROM [Company] 
/* Declaraci�n del cursor para recorrer las compa�ias */
DECLARE [cursorProcess] CURSOR FOR SELECT Name FROM @Listofcompanys;
OPEN [cursorProcess];
FETCH NEXT FROM [cursorProcess] INTO @Company;
/* Generaci�n de la consulta UNION con todas las empresas */
SET @Query = ''
WHILE @@FETCH_STATUS = 0 BEGIN
	SET @Query = @Query + 'SELECT ''' + @Company + ''' as ''Company'', [No_], 
	[Description], [Base Unit of Measure], [Item Category Code], [Product Group Code], 
	[Gross Weight], [Net Weight], [Unit Volume] FROM [' + @Company+ '$Item] UNION ';
	FETCH NEXT FROM [cursorProcess] INTO @Company;
END
/* Quitar el ultimo UNION para corregir la consulta */
SET @Query = SUBSTRING (@Query,1,LEN(@Query)-6);
/* Visualizaci�n y ejecucci�n */
PRINT @Query
EXEC (@Query);
/* Eliminaci�n de cursor */
CLOSE [cursorProcess];
DEALLOCATE [cursorProcess]; 