Use INFO_430_Proj_01

insert into tblPassenger_Type(PassengerTypeName)
values ('Minor'), ('Student'), ('Adult'), ('Senior')

select * from tblPassenger_Type

-- Populate neighborhood table
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_COPY_Neighborhoods')
	BEGIN
		DROP TABLE WORKING_COPY_Neighborhoods

		SELECT * 
		INTO WORKING_COPY_Neighborhoods
		FROM RAW_neighborhoodsData
	END

Select * from WORKING_COPY_Neighborhoods

Select * 
FRom RAW_neighborhoodsData

Select * 
INTO WORKING_COPY_Neighborhoods
FROM RAW_neighborhoodsData

ALTER TABLE tblNeighborhood
ADD ZipCode varchar(50) 

Select * from tblNeighborhood

Insert into tblNeighborhood(NeighborhoodName, ZipCode)
SELECT Neighborhood, ZipCode
FROM WORKING_COPY_Neighborhoods


CREATE PROCEDURE proj01_getPassengerTypeID 
@PTName varchar(50), 
@Passenger_Typey INT OUTPUT
AS
SET @Passenger_Typey = (Select PassengerTypeID from tblPassenger_Type WHERE PassengerTypeName = @PTName)



Select TOP 7000 * 
INTO WORKING_PEEPS_Customers
FROM PEEPS.dbo.tblCUSTOMER

Select * from WORKING_PEEPS_Customers

-- to make sure that we dont have this object already and repopulate it 
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_PEEPS_Customers')
	BEGIN
		DROP TABLE WORKING_PEEPS_Customers

		SELECT * 
		INTO WORKING_PEEPS_Customers
		FROM PEEPS.dbo.tblCUSTOMER
	END

	Select * from tblTransportation


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

	-- View 1: 

	Select * from tblTRANSPORTATION

	EXEC wrapper_insertXport
    @RUN = 10

