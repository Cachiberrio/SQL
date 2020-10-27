SELECT     dbo.[BORRAR$Item Ledger Entry].[Item No_] AS [Producto Nº], dbo.BORRAR$Item.Description AS [Producto Descripción], 
                      dbo.[BORRAR$Item Ledger Entry].[Variant Code] AS [Producto Variante], dbo.[BORRAR$Item Ledger Entry].[Lot No_] AS [Producto Lote], 
                      dbo.BORRAR$Item.[Inventory Posting Group] AS [Producto Grupo contable], dbo.BORRAR$Item.[Cód_ marca] AS [Producto Marca], 
                      dbo.BORRAR$Item.[Cód_ añada] AS [Producto Añada], dbo.BORRAR$Item.[Cód_ formato] AS [Producto Formato], 
                      dbo.BORRAR$Item.[Cód_ color vino] AS [Producto Color], dbo.BORRAR$Item.[Cód_ calificación] AS [Producto Calificación], 
                      dbo.BORRAR$Item.[Cód_ formato botella] AS [Producto Formato botella], dbo.BORRAR$Item.[Cód_ formato caja] AS [Producto Formato caja], 
                      dbo.BORRAR$Item.[Cód_ denominación origen] AS [Producto Denominación Origen], dbo.[BORRAR$Item Ledger Entry].[Location Code] AS [Almacen Código], 
                      dbo.BORRAR$Location.Name AS [Almacen Nombre], dbo.[BORRAR$Item Ledger Entry].[Posting Date] AS Fecha, 
                      dbo.[BORRAR$Item Ledger Entry].Quantity AS Cantidad, dbo.[BORRAR$Item Ledger Entry].Quantity * dbo.BORRAR$Item.[Unit Volume] AS Litros, 
                      ROUND(dbo.[BORRAR$Item Ledger Entry].Quantity * dbo.BORRAR$Item.[Unit Volume] / 9, 0) AS [Cajas de 9], 
                      ROUND(dbo.[BORRAR$Item Ledger Entry].Quantity * dbo.[BORRAR$Formato caja].[No_ botellas _ caja], 0) AS Botellas
FROM         dbo.BORRAR$Item RIGHT OUTER JOIN
                      dbo.[BORRAR$Item Ledger Entry] ON dbo.BORRAR$Item.No_ = dbo.[BORRAR$Item Ledger Entry].[Item No_] LEFT OUTER JOIN
                      dbo.BORRAR$Location ON dbo.[BORRAR$Item Ledger Entry].[Location Code] = dbo.BORRAR$Location.Code LEFT OUTER JOIN
                      dbo.BORRAR$Formato ON dbo.BORRAR$Item.[Cód_ formato] = dbo.BORRAR$Formato.Código LEFT OUTER JOIN
                      dbo.[BORRAR$Formato botella] ON dbo.BORRAR$Item.[Cód_ formato botella] = dbo.[BORRAR$Formato botella].Código LEFT OUTER JOIN
                      dbo.[BORRAR$Formato caja] ON dbo.BORRAR$Item.[Cód_ formato caja] = dbo.[BORRAR$Formato caja].Código