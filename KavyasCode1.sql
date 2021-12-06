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

-- dropping temporarily 
ALTER TABLE tblEmployee
DROP CONSTRAINT ck_age_trprt_type

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

