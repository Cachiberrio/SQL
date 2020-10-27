SELECT     TOP (100) PERCENT dbo.[BORRAR$Value Entry].[Entry Type], dbo.[BORRAR$Value Entry].[Item No_] AS [Producto N�], 
                      dbo.BORRAR$Item.Description AS [Producto Descripci�n], dbo.[BORRAR$Value Entry].[Variant Code] AS [Producto Variante], 
                      dbo.BORRAR$Item.[Inventory Posting Group] AS [Producto Grupo contable], dbo.BORRAR$Item.[C�d_ marca] AS [Producto Marca], 
                      dbo.BORRAR$Item.[C�d_ a�ada] AS [Producto A�ada], dbo.BORRAR$Item.[C�d_ formato] AS [Producto Formato], 
                      dbo.BORRAR$Item.[C�d_ color vino] AS [Producto Color], dbo.BORRAR$Item.[C�d_ calificaci�n] AS [Producto Calificaci�n], 
                      dbo.BORRAR$Item.[C�d_ formato botella] AS [Producto Formato botella], dbo.BORRAR$Item.[C�d_ formato caja] AS [Producto Formato caja], 
                      dbo.BORRAR$Item.[C�d_ denominaci�n origen] AS [Producto Denominaci�n Origen], dbo.[BORRAR$Value Entry].[Location Code] AS [Almacen C�digo], 
                      dbo.BORRAR$Location.Name AS [Almacen Nombre], dbo.[BORRAR$Value Entry].[Posting Date] AS Fecha, dbo.[BORRAR$Value Entry].[Invoiced Quantity] AS Cantidad, 
                      dbo.[BORRAR$Value Entry].[Invoiced Quantity] * dbo.BORRAR$Item.[Unit Volume] AS Litros, 
                      ROUND(dbo.[BORRAR$Value Entry].[Invoiced Quantity] * dbo.BORRAR$Item.[Unit Volume] / 9, 0) AS [Cajas de 9], 
                      ROUND(dbo.[BORRAR$Value Entry].[Invoiced Quantity] * dbo.[BORRAR$Formato caja].[No_ botellas _ caja], 0) AS Botellas, 
                      dbo.[BORRAR$Value Entry].[Source No_] AS [Cliente N�], dbo.BORRAR$Customer.Name AS [Cliente Nombre], dbo.BORRAR$Customer.City AS [Cliente Poblaci�n], 
                      dbo.[BORRAR$Value Entry].[Sales Amount (Actual)] AS [Importe ventas], dbo.[BORRAR$Value Entry].[Discount Amount] AS [Importe descuento], 
                      dbo.BORRAR$Country_Region.Name AS [Cliente pa�s]
FROM         dbo.[BORRAR$Value Entry] LEFT OUTER JOIN
                      dbo.BORRAR$Customer LEFT OUTER JOIN
                      dbo.BORRAR$Country_Region ON dbo.BORRAR$Customer.[Country_Region Code] = dbo.BORRAR$Country_Region.Code ON 
                      dbo.[BORRAR$Value Entry].[Source No_] = dbo.BORRAR$Customer.No_ LEFT OUTER JOIN
                      dbo.BORRAR$Item ON dbo.[BORRAR$Value Entry].[Item No_] = dbo.BORRAR$Item.No_ LEFT OUTER JOIN
                      dbo.BORRAR$Location ON dbo.[BORRAR$Value Entry].[Location Code] = dbo.BORRAR$Location.Code LEFT OUTER JOIN
                      dbo.BORRAR$Formato ON dbo.BORRAR$Item.[C�d_ formato] = dbo.BORRAR$Formato.C�digo LEFT OUTER JOIN
                      dbo.[BORRAR$Formato botella] ON dbo.BORRAR$Item.[C�d_ formato botella] = dbo.[BORRAR$Formato botella].C�digo LEFT OUTER JOIN
                      dbo.[BORRAR$Formato caja] ON dbo.BORRAR$Item.[C�d_ formato caja] = dbo.[BORRAR$Formato caja].C�digo
ORDER BY dbo.[BORRAR$Value Entry].[Entry Type]