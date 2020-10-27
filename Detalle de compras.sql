SELECT        [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Document No_] AS [Documento.No], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Line No_] AS [Documento.No Linea], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Buy-from Vendor No_] AS [Proveedor.No], [CRONUS Espa�a S_A_$Vendor].Name AS [Proveedor.Nombre], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].No_ AS [Producto.No], [CRONUS Espa�a S_A_$Item].Description AS [Producto.Descripcion], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].Quantity AS [Documento.Cantidad], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Direct Unit Cost] AS [Documento.Precio], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Header].[Currency Code] AS [Documento.Divisa], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Unit Cost (LCY)] AS [Documento.Precio (DL)], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Line Discount Amount] AS [Documento.Descuento], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].Amount AS [Documento.Total Linea], 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Amount Including VAT] AS [Documento.Total Linea (IVA incl)]
FROM            [CRONUS Espa�a S_A_$Purch_ Inv_ Header] LEFT OUTER JOIN
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Line] ON 
                         [CRONUS Espa�a S_A_$Purch_ Inv_ Header].No_ = [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Document No_] LEFT OUTER JOIN
                         [CRONUS Espa�a S_A_$Item] ON [CRONUS Espa�a S_A_$Purch_ Inv_ Line].No_ = [CRONUS Espa�a S_A_$Item].No_ LEFT OUTER JOIN
                         [CRONUS Espa�a S_A_$Vendor] ON [CRONUS Espa�a S_A_$Purch_ Inv_ Line].[Buy-from Vendor No_] = [CRONUS Espa�a S_A_$Vendor].No_
WHERE        ([CRONUS Espa�a S_A_$Purch_ Inv_ Line].Type = 2)