/*
====================================================================
Create Database and Schemas
====================================================================
Script Purpose
  This script creates a new database named 'DatWarehouse after checking if it already exists.
  If it already exists, it is dropped and recreated. In addition, this script sets up 3 schemas according to the Medallion Architecture.

WARNING:
  This script will drop the entire database if it already exists. Proceed with caution.
  Ensure you have proper backups before running this script.
*/

--Switching to master.db
USE master;

--Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM  sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

--Create DB
CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
