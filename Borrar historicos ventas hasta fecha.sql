-- Borrado de cabeceras líneas y comentarios de historico de albaranes, facturas y abonos de venta
declare @FechaHasta date = '2009-12-31';

-- Borrado de albaranes venta
delete 
	from dbo.[CRONUS España S_A_$Sales Shipment Line] 
	left outer join dbo.[CRONUS España S_A_$Sales Shipment Header] ON 
		dbo.[CRONUS España S_A_$Sales Shipment Line].[Document No_] = dbo.[CRONUS España S_A_$Sales Shipment Header].No_
	where dbo.[CRONUS España S_A_$Sales Shipment Header].[Posting Date] <= @FechaHasta
delete 
	from dbo.[CRONUS España S_A_$Sales Comment Line] 
	left outer join dbo.[CRONUS España S_A_$Sales Shipment Header] ON 
		dbo.[CRONUS España S_A_$Sales Comment Line].[No_] = dbo.[CRONUS España S_A_$Sales Shipment Header].No_)
 where 
	(dbo.[CRONUS España S_A_$Sales Comment Line] = 6) and 
	(dbo.[CRONUS España S_A_$Sales Shipment Header].[Posting Date] <= @FechaHasta)
delete 
	from dbo.[CRONUS España S_A_$Sales Shipment Header] 
	where dbo.[CRONUS España S_A_$Sales Shipment Header].[Posting Date] <= @FechaHasta

-- Borrado de facturas venta
delete 
	from dbo.[CRONUS España S_A_$Sales Invoice Line] 
	left outer join dbo.[CRONUS España S_A_$Sales Invoice Header] ON 
		dbo.[CRONUS España S_A_$Sales Invoice Line].[Document No_] = dbo.[CRONUS España S_A_$Sales Invoice Header].No_
	where dbo.[CRONUS España S_A_$Sales Invoice Header].[Posting Date] <= @FechaHasta	
delete 
	from dbo.[CRONUS España S_A_$Sales Comment Line] 
	left outer join dbo.[CRONUS España S_A_$Sales Invoice Header] ON 
		dbo.[CRONUS España S_A_$Sales Comment Line].[No_] = dbo.[CRONUS España S_A_$Sales Invoice Header].No_)
 where 
	(dbo.[CRONUS España S_A_$Sales Comment Line] = 7) and 
	(dbo.[CRONUS España S_A_$Sales Invoice Header].[Posting Date] <= @FechaHasta)
delete 
	from dbo.[CRONUS España S_A_$Sales Invoice Header] 
	where dbo.[CRONUS España S_A_$Sales Invoice Header].[Posting Date] <= @FechaHasta

-- Borrado de abonos venta	
delete 
	from dbo.[CRONUS España S_A_$Sales Cr.Memo Line] 
	left outer join dbo.[CRONUS España S_A_$Sales Cr.Memo Header] ON 
		dbo.[CRONUS España S_A_$Sales Cr.Memo Line].[Document No_] = dbo.[CRONUS España S_A_$Sales Cr.Memo Header].No_
	where dbo.[CRONUS España S_A_$Sales Cr.Memo Header].[Posting Date] <= @FechaHasta	
delete 
	from dbo.[CRONUS España S_A_$Sales Comment Line] 
	left outer join dbo.[CRONUS España S_A_$Sales Cr.Memo Header] ON 
		dbo.[CRONUS España S_A_$Sales Comment Line].[No_] = dbo.[CRONUS España S_A_$Sales Cr.Memo Header].No_)
 where 
	(dbo.[CRONUS España S_A_$Sales Comment Line] = 8) and 
	(dbo.[CRONUS España S_A_$Sales Cr.Memo Header].[Posting Date] <= @FechaHasta)
delete 
	from dbo.[CRONUS España S_A_$Sales Cr.Memo Header] 
	where dbo.[CRONUS España S_A_$Sales Cr.Memo Header].[Posting Date] <= @FechaHasta
	
	