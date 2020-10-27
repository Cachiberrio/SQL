SELECT     dbo.[BORRAR$Item Ledger Entry].[Item No_] AS [Producto N�], dbo.BORRAR$Item.Description AS [Producto Descripci�n], 
                      dbo.[BORRAR$Item Ledger Entry].[Variant Code] AS [Producto Variante], dbo.[BORRAR$Item Ledger Entry].[Lot No_] AS [Producto Lote], 
                      dbo.BORRAR$Item.[Inventory Posting Group] AS [Producto Grupo contable], dbo.BORRAR$Item.[C�d_ marca] AS [Producto Marca], 
                      dbo.BORRAR$Item.[C�d_ a�ada] AS [Producto A�ada], dbo.BORRAR$Item.[C�d_ formato] AS [Producto Formato], 
                      dbo.BORRAR$Item.[C�d_ color vino] AS [Producto Color], dbo.BORRAR$Item.[C�d_ calificaci�n] AS [Producto Calificaci�n], 
                      dbo.BORRAR$Item.[C�d_ formato botella] AS [Producto Formato botella], dbo.BORRAR$Item.[C�d_ formato caja] AS [Producto Formato caja], 
                      dbo.BORRAR$Item.[C�d_ denominaci�n origen] AS [Producto Denominaci�n Origen], dbo.[BORRAR$Item Ledger Entry].[Location Code] AS [Almacen C�digo], 
                      dbo.BORRAR$Location.Name AS [Almacen Nombre], dbo.[BORRAR$Item Ledger Entry].[Posting Date] AS Fecha, 
                      dbo.[BORRAR$Item Ledger Entry].Quantity AS Cantidad, dbo.[BORRAR$Item Ledger Entry].Quantity * dbo.BORRAR$Item.[Unit Volume] AS Litros, 
                      ROUND(dbo.[BORRAR$Item Ledger Entry].Quantity * dbo.BORRAR$Item.[Unit Volume] / 9, 0) AS [Cajas de 9], 
                      ROUND(dbo.[BORRAR$Item Ledger Entry].Quantity * dbo.[BORRAR$Formato caja].[No_ botellas _ caja], 0) AS Botellas
FROM         dbo.BORRAR$Item RIGHT OUTER JOIN
                      dbo.[BORRAR$Item Ledger Entry] ON dbo.BORRAR$Item.No_ = dbo.[BORRAR$Item Ledger Entry].[Item No_] LEFT OUTER JOIN
                      dbo.BORRAR$Location ON dbo.[BORRAR$Item Ledger Entry].[Location Code] = dbo.BORRAR$Location.Code LEFT OUTER JOIN
                      dbo.BORRAR$Formato ON dbo.BORRAR$Item.[C�d_ formato] = dbo.BORRAR$Formato.C�digo LEFT OUTER JOIN
                      dbo.[BORRAR$Formato botella] ON dbo.BORRAR$Item.[C�d_ formato botella] = dbo.[BORRAR$Formato botella].C�digo LEFT OUTER JOIN
                      dbo.[BORRAR$Formato caja] ON dbo.BORRAR$Item.[C�d_ formato caja] = dbo.[BORRAR$Formato caja].C�digo