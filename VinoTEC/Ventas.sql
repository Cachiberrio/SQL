SELECT     TOP (100) PERCENT dbo.[BORRAR$Value Entry].[Entry Type], dbo.[BORRAR$Value Entry].[Item No_] AS [Producto Nº], 
                      dbo.BORRAR$Item.Description AS [Producto Descripción], dbo.[BORRAR$Value Entry].[Variant Code] AS [Producto Variante], 
                      dbo.BORRAR$Item.[Inventory Posting Group] AS [Producto Grupo contable], dbo.BORRAR$Item.[Cód_ marca] AS [Producto Marca], 
                      dbo.BORRAR$Item.[Cód_ añada] AS [Producto Añada], dbo.BORRAR$Item.[Cód_ formato] AS [Producto Formato], 
                      dbo.BORRAR$Item.[Cód_ color vino] AS [Producto Color], dbo.BORRAR$Item.[Cód_ calificación] AS [Producto Calificación], 
                      dbo.BORRAR$Item.[Cód_ formato botella] AS [Producto Formato botella], dbo.BORRAR$Item.[Cód_ formato caja] AS [Producto Formato caja], 
                      dbo.BORRAR$Item.[Cód_ denominación origen] AS [Producto Denominación Origen], dbo.[BORRAR$Value Entry].[Location Code] AS [Almacen Código], 
                      dbo.BORRAR$Location.Name AS [Almacen Nombre], dbo.[BORRAR$Value Entry].[Posting Date] AS Fecha, dbo.[BORRAR$Value Entry].[Invoiced Quantity] AS Cantidad, 
                      dbo.[BORRAR$Value Entry].[Invoiced Quantity] * dbo.BORRAR$Item.[Unit Volume] AS Litros, 
                      ROUND(dbo.[BORRAR$Value Entry].[Invoiced Quantity] * dbo.BORRAR$Item.[Unit Volume] / 9, 0) AS [Cajas de 9], 
                      ROUND(dbo.[BORRAR$Value Entry].[Invoiced Quantity] * dbo.[BORRAR$Formato caja].[No_ botellas _ caja], 0) AS Botellas, 
                      dbo.[BORRAR$Value Entry].[Source No_] AS [Cliente Nº], dbo.BORRAR$Customer.Name AS [Cliente Nombre], dbo.BORRAR$Customer.City AS [Cliente Población], 
                      dbo.[BORRAR$Value Entry].[Sales Amount (Actual)] AS [Importe ventas], dbo.[BORRAR$Value Entry].[Discount Amount] AS [Importe descuento], 
                      dbo.BORRAR$Country_Region.Name AS [Cliente país]
FROM         dbo.[BORRAR$Value Entry] LEFT OUTER JOIN
                      dbo.BORRAR$Customer LEFT OUTER JOIN
                      dbo.BORRAR$Country_Region ON dbo.BORRAR$Customer.[Country_Region Code] = dbo.BORRAR$Country_Region.Code ON 
                      dbo.[BORRAR$Value Entry].[Source No_] = dbo.BORRAR$Customer.No_ LEFT OUTER JOIN
                      dbo.BORRAR$Item ON dbo.[BORRAR$Value Entry].[Item No_] = dbo.BORRAR$Item.No_ LEFT OUTER JOIN
                      dbo.BORRAR$Location ON dbo.[BORRAR$Value Entry].[Location Code] = dbo.BORRAR$Location.Code LEFT OUTER JOIN
                      dbo.BORRAR$Formato ON dbo.BORRAR$Item.[Cód_ formato] = dbo.BORRAR$Formato.Código LEFT OUTER JOIN
                      dbo.[BORRAR$Formato botella] ON dbo.BORRAR$Item.[Cód_ formato botella] = dbo.[BORRAR$Formato botella].Código LEFT OUTER JOIN
                      dbo.[BORRAR$Formato caja] ON dbo.BORRAR$Item.[Cód_ formato caja] = dbo.[BORRAR$Formato caja].Código
ORDER BY dbo.[BORRAR$Value Entry].[Entry Type]