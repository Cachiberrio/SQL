Select
  "Hº Cab_ parte bodega"."Nº documento",
  "Tipo trabajo".Descripción,
  "Hº Cab_ parte bodega".Descripción,
  "Producto Entradas".Nº,
  "Hº Lín_ entrada parte bodega"."Cód_ variante",
  "Producto Entradas".Descripción,
  "Hº Lín_ entrada parte bodega"."Nº lote",
  "Hº Lín_ entrada parte bodega"."Cód_ almacén",
  "Hº Lín_ entrada parte bodega".Cantidad,
  "Hº Lín_ entrada parte bodega"."Coste total"
From
  "Hº Cab_ parte bodega" Left Outer Join
  "Hº Lín_ entrada parte bodega" On "Hº Cab_ parte bodega"."Nº documento" =
    "Hº Lín_ entrada parte bodega"."Nº documento" Left Outer Join
  "Tipo trabajo" On "Hº Cab_ parte bodega"."Cód_ tipo trabajo" =
    "Tipo trabajo".Código Left Outer Join
  Producto "Producto Entradas" On "Hº Lín_ entrada parte bodega".Nº =
    "Producto Entradas".Nº

union

Select
  "Hº Cab_ parte bodega"."Nº documento",
  "Tipo trabajo".Descripción,
  "Hº Cab_ parte bodega".Descripción,
  "Producto Entradas".Nº,
  "Hº Lín_ entrada parte bodega"."Cód_ variante",
  "Producto Entradas".Descripción,
  "Hº Lín_ salida parte bodega"."Nº lote",
  "Hº Lín_ salida parte bodega"."Cód_ almacén",
  "Hº Lín_ salida parte bodega".Cantidad,
  "Hº Lín_ salida parte bodega"."Coste total"
From
  "Hº Cab_ parte bodega" Left Outer Join
  "Hº Lín_ salida parte bodega" On "Hº Cab_ parte bodega"."Nº documento" =
    "Hº Lín_ salida parte bodega"."Nº documento" Left Outer Join
  "Tipo trabajo" On "Hº Cab_ parte bodega"."Cód_ tipo trabajo" =
    "Tipo trabajo".Código Left Outer Join
  Producto "Producto Entradas" On "Hº Lín_ salida parte bodega".Nº =
    "Producto Entradas".Nº