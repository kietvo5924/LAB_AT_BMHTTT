USE [master];
GO

IF DB_ID(N'LAB1_MaHoaCoDien_VoAnhKiet') IS NULL
BEGIN
    CREATE DATABASE [LAB1_MaHoaCoDien_VoAnhKiet];
END;
GO

USE [LAB1_MaHoaCoDien_VoAnhKiet];
GO

IF OBJECT_ID(N'dbo.history', N'U') IS NULL 
BEGIN
    CREATE TABLE dbo.history (
        id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
        student_name NVARCHAR(100) NOT NULL DEFAULT N'Võ Anh Ki?t',
        algorithm NVARCHAR(50) NOT NULL, 
        operation VARCHAR(10) NOT NULL, 
        input_text NVARCHAR(MAX) NOT NULL, 
        result_text NVARCHAR(MAX) NOT NULL,
        CONSTRAINT CK_lab1_operation CHECK (operation IN ('ENCRYPT','DECRYPT'))
    );
END;
GO

USE [master];
GO
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'lab1_user') 
BEGIN
    CREATE LOGIN [lab1_user] WITH PASSWORD = '123456', CHECK_POLICY = OFF;
END;
GO

USE [LAB1_MaHoaCoDien_VoAnhKiet];
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'lab1_user') 
BEGIN
    CREATE USER [lab1_user] FOR LOGIN [lab1_user];
END;
GO

GRANT SELECT, INSERT, DELETE ON OBJECT::dbo.history TO [lab1_user];
GO

SELECT DB_NAME() AS Database_Name, N'Võ Anh Ki?t - 1150080143' AS Sinh_Vien, COUNT(*) AS So_Ban_Ghi FROM dbo.history;
GO