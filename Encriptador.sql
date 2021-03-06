/****** Script para el comando SelectTopNRows de SSMS  ******/
use I_Cal

--Almaceno en CF el codigo fuente
DECLARE @CF nvarchar (max)
SET @CF = (SELECT [sysCalculoFuente] FROM [I_Cal].[dbo].[lsysScripts] where sysid='A_HolaMundo')
SELECT @CF as CalculoFuente
--Encripto CF con la frase pendeja y lo guardo en CFE
DECLARE @CFE varbinary (max)
SET @CFE = (ENCRYPTBYPASSPHRASE('Viva Mejico, Cabrones!',@CF))
SELECT @CFE as CalculoFuenteEncriptado, 'JaJaJaJa donde esta el calculo' as Mensaje
--Vuelvo a descriptarla con la misma frase y lo muestro en CFD
DECLARE @CFD nvarchar(max)
SET @CFD = (DECRYPTBYPASSPHRASE('Viva Mejico, Cabrones!',@CFE))
SELECT @CFD AS CalculoFuenteDesencriptado
