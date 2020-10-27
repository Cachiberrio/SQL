SELECT

so.name AS Tabla,
sc.name AS Columna,
st.name AS Tipo,
sc.max_length AS Tamaño

FROM

sys.objects so INNER JOIN
sys.columns sc ON
so.object_id = sc.object_id INNER JOIN
sys.types st ON
st.system_type_id = sc.system_type_id AND
st.name != 'sysname'

WHERE

so.type = 'U' AND SO.name = 'Poner nombre de la tabla a listar'

ORDER BY

so.name, SC.column_id