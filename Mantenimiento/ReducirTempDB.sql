use tempdb
   go

   dbcc shrinkfile (tempdev, 100)
   go
   -- this command shrinks the primary data file

   dbcc shrinkfile (templog, 100)
   go
   -- this command shrinks the log file, examine the last paragraph.