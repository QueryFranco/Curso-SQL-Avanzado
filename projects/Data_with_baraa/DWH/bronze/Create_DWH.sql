/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
-- 1. CERRAR CONEXIONES Y ELIMINAR LA BD (Equivalente al ALTER DATABASE ... SET SINGLE_USER)
-- (Debes ejecutar esto estando conectado a la base de datos por defecto 'postgres')
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'DataWarehouse'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS "DataWarehouse";


-- 2. CREAR LA BASE DE DATOS
CREATE DATABASE "DataWarehouse";


-- [NOTA CRÍTICA DE CONEXIÓN]: 
-- En Postgres no existe el comando "USE". 
-- En este punto, haz clic abajo a la izquierda en tu VS Code y 
-- cambia la conexión activa de 'postgres' a 'DataWarehouse' para ejecutar lo siguiente:


-- 3. CREAR LOS ESQUEMAS
CREATE SCHEMA IF NOT EXISTS bronze; 
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

