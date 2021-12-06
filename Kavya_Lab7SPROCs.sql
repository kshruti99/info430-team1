/* Kavya Iyer
Lab 6
SPROC - Insert into Passenger*/

-- 1. Create Procedure for lookup table

USE INFO_430_Proj_01

IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_PEEPS_Customers')
	BEGIN
		DROP TABLE WORKING_PEEPS_Customers

		SELECT TOP 7000 * 
		INTO WORKING_PEEPS_Customers
		FROM PEEPS.dbo.tblCUSTOMER
	END



CREATE PROCEDURE proj01_getPassengerTypeID 
@PTName varchar(50), 
@Passenger_Typey INT OUTPUT
AS
SET @Passenger_Typey = (Select PassengerTypeID from tblPassenger_Type WHERE PassengerTypeName = @PTName)


-- base stored proc
CREATE PROCEDURE insertPassenger
@Firsty varchar(50), 
@Lasty varchar(50), 
@Birthy DATE, 
@Emaily varchar(50), 
@ptypeName varchar(50)
AS 
DECLARE @TYPY_ID INT

EXEC  proj01_getPassengerTypeID 
@PTName = @ptypeName, 
@Passenger_Typey = @TYPY_ID OUTPUT 

-- error handling
IF @TYPY_ID IS NULL 
	BEGIN 
		PRINT 'PASSENGER TYPE ID IS NULL, PLEASE FIX'
		RAISERROR ('CHECK SPELLING OF PSNGR TYPE', 11, 1)
		RETURN
	END 

BEGIN TRAN T1
INSERT INTO TBLPASSENGER(PassengerTypeID, PassengerFirstName, PassengerLastName, PassengerDOB, 
						PassengerEmail)
	VALUES (@TYPY_ID, @FIRSTY, @LASTY, @BIRTHY, @EMAILY)

IF @@ERROR <> 0 
	BEGIN 
		ROLLBACK TRAN T1 
	END
ELSE 
	COMMIT TRAN T1
GO 

exec insertPassenger
@Firsty = 'Kavya', 
@Lasty = 'Iyer', 
@Birthy = '1999-02-11', 
@Emaily = 'kavyai@uw.edu', 
@ptypeName = 'Student'
select * from tblPASSENGER


-- write wrapper 
ALTER PROCEDURE wrapper_insertPassenger
@RUN INT
AS
DECLARE @PT_PK INT
DECLARE @PT_COUNT INT = (SELECT COUNT(*) FROM TBLPASSENGER_TYPE)
DECLARE @PEEP_PK INT
DECLARE @PEEP_COUNT INT = (SELECT COUNT(*) FROM WORKING_PEEPS_Customers)
DECLARE @FNAME varchar(50), @LNAME varchar(50), @DOBBY DATE, @PEMAIL varchar(50), 
@PASSTypName varchar(50)

WHILE @RUN > 0 
BEGIN 
SET @PT_PK = (SELECT RAND() * @PT_COUNT + 1) 
SET @PEEP_PK = (SELECT MIN(CustomerID) FROM WORKING_PEEPS_Customers) 
SET @PASSTypName = (SELECT PassengerTypeName from tblPASSENGER_TYPE WHERE PassengerTypeID = @PT_PK)
SET @FNAME = (SELECT CustomerFName FROM WORKING_PEEPS_Customers WHERE CustomerID = @PEEP_PK)
SET @LNAME = (SELECT CUSTOMERLNAME FROM WORKING_PEEPS_Customers WHERE CustomerID = @PEEP_PK)
SET @DOBBY = (SELECT DATEOFBIRTH FROM WORKING_PEEPS_Customers WHERE CustomerID = @PEEP_PK)
SET @PEMAIL = (SELECT EMAIL FROM WORKING_PEEPS_Customers WHERE CustomerID = @PEEP_PK)


EXEC insertPassenger
@Firsty = @FNAME, 
@Lasty  = @LNAME, 
@Birthy = @DOBBY, 
@Emaily = @PEMAIL, 
@ptypeName = @PASSTYPNAME

set @RUN = @RUN - 1
DELETE FROM WORKING_PEEPS_Customers
	WHERE CustomerID = @PEEP_PK
END

EXEC wrapper_insertPassenger 2000

Select * from tblPASSENGER

Select * from tblPASSENGER_TYPE

Select * from PEEPS.dbo.tblCUSTOMER

Select distinct count(*) from tblPASSENGER

Select * from WORKING_PEEPS_Customers



-- Populate tblTransportation!!!
-- vehicle, route, employee
CREATE PROCEDURE proj01_insert_xport
@VeName varchar(50),
@RouName varchar(50),
@EFName varchar(50),
@ELName varchar(50),
@EmpDOB DATE
AS
DECLARE @V_ID INT, @E_ID INT, @R_ID INT

EXEC GetVehicleID
@VName = @VeName,
@VID = @V_ID OUTPUT
IF @V_ID IS NULL
	BEGIN
		PRINT 'Vehicle ID IS NULL, PLEASE FIX'
		RAISERROR ('CHECK SPELLING OF Vehicle', 11, 1)
		RETURN
	END

EXEC GetRouteID
@RName = @RouName,
@Routy = @R_ID OUTPUT
IF @R_ID IS NULL
	BEGIN
		PRINT 'Route ID IS NULL, PLEASE FIX'
		RAISERROR ('CHECK SPELLING OF Route', 11, 1)
		RETURN
	END

EXEC GetEmployeeID
@EFirstName = @EFName,
@ELastName = @ELName,
@EDOB = @EmpDOB,
@Empy = @E_ID OUTPUT
IF @E_ID IS NULL
	BEGIN
		PRINT 'Emp ID IS NULL, PLEASE FIX'
		RAISERROR ('CHECK SPELLING OF Emp', 11, 1)
		RETURN
	END

BEGIN TRAN T1
INSERT INTO tblTRANSPORTATION(VehicleID, RouteID, EmployeeID)
	VALUES (@V_ID, @R_ID, @E_ID)

IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN T1
	END
ELSE
	COMMIT TRAN T1
GO

-- Wrapper
ALTER PROCEDURE wrapper_insertXport
@RUN INT
AS
DECLARE @E_PK INT
DECLARE @E_COUNT INT = (SELECT COUNT(*) FROM tblEMPLOYEE)
DECLARE @R_PK INT
DECLARE @R_COUNT INT = (SELECT COUNT(*) FROM tblROUTE)
DECLARE @V_PK INT
DECLARE @V_COUNT INT = (Select COUNT(*) from tblVEHICLE)
DECLARE @VN varchar(50), @RN varchar(30), @EFN varchar(30), @ELN varchar(30), @EDOB Date


WHILE @RUN > 0
BEGIN

    SET @E_PK = (SELECT RAND() * @E_COUNT + 1 + 1002)
    SET @EFN = (SELECT employeeFirstName FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
    SET @ELN = (SELECT EmployeeLastName FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
    SET @EDOB = (SELECT EmployeeDOB FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)

    SET @R_PK = (SELECT RAND() * @R_COUNT + 1)
    SET @RN = (SELECT RouteName FROM tblROUTE WHERE RouteID = @R_PK)

    SET @V_PK = (SELECT RAND() * @V_COUNT + 1)
    SET @VN = (SELECT VehicleName from tblVEHICLE WHERE VehicleID = @V_PK)

EXEC proj01_insert_xport
@VeName = @VN,
@RouName = @RN,
@EFName = @EFN,
@ELName = @ELN,
@EmpDOB = @EDOB

SET @RUN = @RUN - 1

END
GO



	Select * from tblTRANSPORTATION
	ORDER BY EmployeeID

	EXEC Wrapper_INSERT_BOARDING @RUN = 100

	Select * from tblBOARDING
	Select * from tblTRANSPORTATION
