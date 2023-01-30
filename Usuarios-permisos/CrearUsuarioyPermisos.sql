/* Desde Management Studio con inicio sesión Azure AD - usuario administrador del servicio de SQL
*/

-- Conexión a BD master
CREATE LOGIN Usuario WITH PASSWORD = 'Contraseña';

-- Conexión a BD
CREATE USER [Usuario]
FOR LOGIN [Usuario]
--WITH DEFAULT_SCHEMA = db_owner; -- db_datareader, db_owner, ...
EXEC sp_addrolemember 'db_datareader', [Usuario]; -- db_datareader, db_owner, ...