-- KAVYA'S CODE

-- Sproc 1: Insert into Passenger + Populate
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


-- Sproc 2: Update Passenger Information
Select * from tblPASSENGER


CREATE PROCEDURE proj01_updatePassenger
@P_ID INT,
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

BEGIN 
	UPDATE tblPASSENGER
		SET PassengerFirstName = @Firsty, 
		PassengerLastName = @Lasty, 
		PassengerDOB = @Birthy,
		PassengerEmail = @Emaily, 
		PassengerTypeID = @TYPY_ID
		WHERE PassengerID = @P_ID
	END
RETURN 0 

-- testing
exec proj01_updatePassenger
@P_ID = 1,
@Firsty = 'Kavie', 
@Lasty = ' Iyer', 
@Birthy = '11/03/1999', 
@Emaily = 'kavyee@uw.edu', 
@ptypeName = 'Student'

Select * from tblPASSENGER 
WHERE PassengerID = 1



-- Populate tblTransportation 

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

-- Business rule 1: Employees MUST be older than 25 to work on 
--Double-Decker, Guided, and Open top Buses
-- Employee, Transportation, Vehicle, Vehicle Type
CREATE FUNCTION dbo.proj01_employeeAge()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (SELECT * from tblEMPLOYEE E 
			JOIN tblTRANSPORTATION T on E.EmployeeID = T.EmployeeID
			JOIN tblVEHICLE V on T.VehicleID = V.VehicleID
			JOIN tblVEHICLE_TYPE VT on V.VehicleTypeID = VT.VehicleTypeID
			WHERE VT.VehicleTypeID = 5 
			OR VT.VehicleTypeID = 8
			OR VT.VehicleTypeID = 11
			AND E.EmployeeDOB > DateAdd(Year, -25, GetDate()))
			BEGIN
                SET @RET = 1
            END
RETURN @RET
END
GO


ALTER TABLE tblEmployee with nocheck
ADD CONSTRAINT ck_age_trprt_type
CHECK(dbo.proj01_employeeAge() = 0)


-- Business Rule 2: Only passengers with edu emails can be classified as Student Passenger Type
ALTER FUNCTION dbo.ck_student_passType()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF EXISTS (SELECT * from tblPASSENGER P 
		JOIN tblPASSENGER_TYPE PT on P.PassengerTypeID = PT.PassengerTypeID
		WHERE PT.PassengerTypeName = 'Student'
		AND P.PassengerEmail LIKE '%.edu')
		SET @RET = 1
	RETURN @RET
END 
GO

ALTER TABLE tblPassenger with nocheck
ADD CONSTRAINT check_edu_PassengerType
CHECK (dbo.ck_student_passType() = 0)
GO

-- Computed Column 1: Average age of each passenger type
CREATE FUNCTION FN_PassType_AvgAge(@PK INTEGER)
RETURNS NUMERIC (4, 1)
AS 
BEGIN

DECLARE @RET NUMERIC = (SELECT AVG(DATEDIFF(YEAR, P.PassengerDOB, GETDATE())) FROM tblPASSENGER P 
						JOIN tblPASSENGER_TYPE PT ON P.PassengerTypeID = PT.PassengerTypeID
						WHERE PT.PassengerTypeID = @PK)
						RETURN @RET
						END 
						GO
	ALTER TABLE tblPassenger_Type
	ADD FN_PassType_AvgAge
	AS (DBO.FN_PassType_AvgAge(PassengerTypeID))

-- Computed Column 2: Number of boardings (aka rides) for each passenger 
CREATE FUNCTION FN_Num_Boardings(@PK INTEGER)
RETURNS INTEGER 
AS 
BEGIN 
DECLARE @RET INTEGER = (Select COUNT(B.BoardingID) FROM tblBOARDING B 
						JOIN tblPASSENGER P on B.PassengerID = P.PassengerID
						WHERE P.PassengerID = @PK)
						RETURN @RET
						END 
						GO 
	ALTER TABLE tblPassenger
	ADD FN_Num_Boardings
	AS (DBO.FN_Num_Boardings(PassengerID))

	Select * from tblPASSENGER

	-- View 1: 10th oldest person who has ever taken a shuttle bus to Central Bronx
	create view vw_old_bronx_bus
	as 
	(select p.passengerid, p.passengerfirstname, p.passengerlastname,
		DENSE_RANK() OVER (ORDER BY P.PassengerDOB DESC) AS oldestRanked
		FROM tblPassenger p 
		join tblBoarding B on p.passengerID = b.PassengerID 
		join tblStop S on B.StopID  = S.StopID
		join tblNEIGHBORHOOD N on S.NeighborhoodID = N.NeighborhoodID
		join tblTRANSPORTATION T on B.TransportationID = T.TransportationID
		join tblVEHICLE V on T.VehicleID = V.VehicleID
		join tblVEHICLE_TYPE VT on V.VehicleTypeID = VT.VehicleTypeID
		WHERE VT.VehicleTypeName = 'shuttle bus'
		AND N.NeighborhoodName = 'Central Bronx')
	
	select * from vw_old_bronx_bus
	WHERE oldestRanked = 10

	select * from tblEMPLOYEE

	-- View 2: Who meets the following conditions: 
	--employees of type bus driver who have driven school buses in Southwest Brooklyn 
	--who are also born in between June 1, 1957 and June 1, 1987

	CREATE VIEW vw_brooklyn_schoolbus 
	AS 
	SELECT E.EmployeeID, E.EmployeeFirstName, E.EmployeeLastName
	FROM tblEMPLOYEE E 
	JOIN tblEMPLOYEE_TYPE ET on E.EmployeeTypeID = ET.EmployeeTypeID
	JOIN tblTRANSPORTATION T on E.EmployeeID = T.EmployeeID
	join tblVEHICLE V on T.VehicleID = V.VehicleID
	join tblVEHICLE_TYPE VT  on V.VehicleTypeID = VT.VehicleTypeID
	join tblBoarding B on T.TransportationID = B.TransportationID
	join tblSTOP S on B.StopID = S.StopID
	join tblNEIGHBORHOOD N on S.NeighborhoodID = N.NeighborhoodID
	WHERE VT.VehicleTypeName = 'School bus'
	AND N.NeighborhoodName = 'Southwest Brooklyn'
	AND ET.EmployeeTypeName = 'Bus driver'

	CREATE VIEW vw_driver_age_range
	AS
	SELECT E.EmployeeID, E.EmployeeFirstName, E.EmployeeLastName, E.EmployeeDOB
	from tblEMPLOYEE E 
	WHERE E.EmployeeDOB BETWEEN '06/01/1957' AND '06/01/1987'

Select A.EmployeeID, A.EmployeeFirstName, A.EmployeeLastName, B.EmployeeDOB
from vw_brooklyn_schoolbus A
join vw_driver_age_range B on A.EmployeeID = B.EmployeeID