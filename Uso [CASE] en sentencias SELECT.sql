SELECT     dbo.[CRONUS España S_A_$Sales Invoice Header].No_ AS NoDoc, dbo.[CRONUS España S_A_$Sales Invoice Line].[Line No_] AS NoLin, 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].[Bill-to Customer No_] AS CodCliente, 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].[Posting Date] AS FechaRegistro, 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].[Payment Method Code] AS CodMetodoPago, 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].[Payment Terms Code] AS CodTerminoPago, 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].[Currency Code] AS CodDivisa, 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].[Customer Price Group] AS CodGrupoPrecioCliente, 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].[Salesperson Code] AS CodVendedor, 
                      CASE WHEN dbo.[CRONUS España S_A_$Sales Invoice Line].Type = 4 THEN 'Act. Fijo' WHEN dbo.[CRONUS España S_A_$Sales Invoice Line].Type = 1 THEN 'Cuenta'
                       WHEN dbo.[CRONUS España S_A_$Sales Invoice Line].Type = 2 THEN 'Producto' WHEN dbo.[CRONUS España S_A_$Sales Invoice Line].Type = 3 THEN 'Recurso' END
                       AS Tipo, dbo.[CRONUS España S_A_$Sales Invoice Line].No_ AS CodProducto, dbo.[CRONUS España S_A_$Sales Invoice Line].[Location Code] AS CodAlmacen, 
                      dbo.[CRONUS España S_A_$Sales Invoice Line].[Quantity (Base)] AS [Cantidad (Base)], dbo.[CRONUS España S_A_$Sales Invoice Line].Quantity AS Cantidad, 
                      dbo.[CRONUS España S_A_$Sales Invoice Line].[Unit Price] AS PrecioUnitario, dbo.[CRONUS España S_A_$Sales Invoice Line].[Line Discount Amount] AS TotalDto, 
                      dbo.[CRONUS España S_A_$Sales Invoice Line].Amount AS TotalLinea, dbo.[CRONUS España S_A_$Sales Invoice Line].[Amount Including VAT] AS TotalLineaIVA
FROM         dbo.[CRONUS España S_A_$Sales Invoice Header] LEFT OUTER JOIN
                      dbo.[CRONUS España S_A_$Sales Invoice Line] ON 
                      dbo.[CRONUS España S_A_$Sales Invoice Header].No_ = dbo.[CRONUS España S_A_$Sales Invoice Line].[Document No_]
WHERE     (dbo.[CRONUS España S_A_$Sales Invoice Line].Type <> 0) OR
                      (dbo.[CRONUS España S_A_$Sales Invoice Line].Type = 5)