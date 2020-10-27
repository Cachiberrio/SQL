USE MiBaseDatos;
CHECKPOINT
BACKUP DATABASE MiBaseDatos TO DISK='D:\MiBaseDatos.bak';
DBCC SHRINKDATABASE (MiBaseDatos);
'DBCC SHRINKFILE (ArchivoTransacciones.ldf); 