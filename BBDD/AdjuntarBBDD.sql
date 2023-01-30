# Scripts para adjuntar BBDD

USE [master]
GO
CREATE DATABASE [AdventureWorks2017] ON
( FILENAME = N'D:\AdventureWorks2017.mdf' ),
( FILENAME = N'D:\AdventureWorks2017_log.ldf' )
 FOR ATTACH
GO

