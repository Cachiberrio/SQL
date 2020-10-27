Select
  "H� Cab_ parte bodega"."N� documento",
  "Tipo trabajo".Descripci�n,
  "H� Cab_ parte bodega".Descripci�n,
  "Producto Entradas".N�,
  "H� L�n_ entrada parte bodega"."C�d_ variante",
  "Producto Entradas".Descripci�n,
  "H� L�n_ entrada parte bodega"."N� lote",
  "H� L�n_ entrada parte bodega"."C�d_ almac�n",
  "H� L�n_ entrada parte bodega".Cantidad,
  "H� L�n_ entrada parte bodega"."Coste total"
From
  "H� Cab_ parte bodega" Left Outer Join
  "H� L�n_ entrada parte bodega" On "H� Cab_ parte bodega"."N� documento" =
    "H� L�n_ entrada parte bodega"."N� documento" Left Outer Join
  "Tipo trabajo" On "H� Cab_ parte bodega"."C�d_ tipo trabajo" =
    "Tipo trabajo".C�digo Left Outer Join
  Producto "Producto Entradas" On "H� L�n_ entrada parte bodega".N� =
    "Producto Entradas".N�

union

Select
  "H� Cab_ parte bodega"."N� documento",
  "Tipo trabajo".Descripci�n,
  "H� Cab_ parte bodega".Descripci�n,
  "Producto Entradas".N�,
  "H� L�n_ entrada parte bodega"."C�d_ variante",
  "Producto Entradas".Descripci�n,
  "H� L�n_ salida parte bodega"."N� lote",
  "H� L�n_ salida parte bodega"."C�d_ almac�n",
  "H� L�n_ salida parte bodega".Cantidad,
  "H� L�n_ salida parte bodega"."Coste total"
From
  "H� Cab_ parte bodega" Left Outer Join
  "H� L�n_ salida parte bodega" On "H� Cab_ parte bodega"."N� documento" =
    "H� L�n_ salida parte bodega"."N� documento" Left Outer Join
  "Tipo trabajo" On "H� Cab_ parte bodega"."C�d_ tipo trabajo" =
    "Tipo trabajo".C�digo Left Outer Join
  Producto "Producto Entradas" On "H� L�n_ salida parte bodega".N� =
    "Producto Entradas".N�