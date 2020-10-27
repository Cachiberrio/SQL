SELECT        [CRONUS España S_A_$Purch_ Inv_ Line].[Document No_] AS [Documento.No], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].[Line No_] AS [Documento.No Linea], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].[Buy-from Vendor No_] AS [Proveedor.No], [CRONUS España S_A_$Vendor].Name AS [Proveedor.Nombre], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].No_ AS [Producto.No], [CRONUS España S_A_$Item].Description AS [Producto.Descripcion], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].Quantity AS [Documento.Cantidad], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].[Direct Unit Cost] AS [Documento.Precio], 
                         [CRONUS España S_A_$Purch_ Inv_ Header].[Currency Code] AS [Documento.Divisa], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].[Unit Cost (LCY)] AS [Documento.Precio (DL)], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].[Line Discount Amount] AS [Documento.Descuento], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].Amount AS [Documento.Total Linea], 
                         [CRONUS España S_A_$Purch_ Inv_ Line].[Amount Including VAT] AS [Documento.Total Linea (IVA incl)]
FROM            [CRONUS España S_A_$Purch_ Inv_ Header] LEFT OUTER JOIN
                         [CRONUS España S_A_$Purch_ Inv_ Line] ON 
                         [CRONUS España S_A_$Purch_ Inv_ Header].No_ = [CRONUS España S_A_$Purch_ Inv_ Line].[Document No_] LEFT OUTER JOIN
                         [CRONUS España S_A_$Item] ON [CRONUS España S_A_$Purch_ Inv_ Line].No_ = [CRONUS España S_A_$Item].No_ LEFT OUTER JOIN
                         [CRONUS España S_A_$Vendor] ON [CRONUS España S_A_$Purch_ Inv_ Line].[Buy-from Vendor No_] = [CRONUS España S_A_$Vendor].No_
WHERE        ([CRONUS España S_A_$Purch_ Inv_ Line].Type = 2)