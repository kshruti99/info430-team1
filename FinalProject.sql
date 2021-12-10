USE INFO_430_Proj_01;

CREATE TABLE tblEMPLOYEE_TYPE
(EmployeeTypeID INT IDENTITY(1,1) primary key,
EmployeeTypeName varchar(50) not null)
GO

CREATE TABLE tblEMPLOYEE
(EmployeeID INT IDENTITY(1,1) primary key,
EmployeeTypeID INT FOREIGN KEY REFERENCES tblEMPLOYEE_TYPE (EmployeeTypeID) not null,
EmployeeFirstName varchar(50) not null,
EmployeeLastName varchar(50) not null,
EmployeeDOB Date not null)
GO

CREATE TABLE tblROUTE
(RouteID INT IDENTITY(1,1) primary key,
RouteName varchar(50) not null)
GO

CREATE TABLE tblROUTE_EMPLOYEE
(Route_EmployeeID INT IDENTITY(1,1) primary key,
RouteID INT FOREIGN KEY REFERENCES tblROUTE (RouteID) null,
EmployeeID INT FOREIGN KEY REFERENCES tblEMPLOYEE (EmployeeID) not null)
GO

CREATE TABLE tblVEHICLE_TYPE
(VehicleTypeID INT IDENTITY(1,1) primary key,
VehicleTypeName varchar(50) not null)
GO

CREATE TABLE tblVEHICLE
(VehicleID INT IDENTITY(1,1) primary key,
VehicleTypeID INT FOREIGN KEY REFERENCES tblVEHICLE_TYPE (VehicleTypeID) not null)
GO

CREATE TABLE tblTRANSPORTATION
(TransportationID INT IDENTITY(1,1) primary key,
VehicleID INT FOREIGN KEY REFERENCES tblVEHICLE (VehicleID) not null,
RouteID INT FOREIGN KEY REFERENCES tblROUTE (RouteID) not null,
EmployeeID INT FOREIGN KEY REFERENCES tblEMPLOYEE (EmployeeID) not null)
GO

CREATE TABLE tblNEIGHBORHOOD
(NeighborhoodID INT IDENTITY(1,1) primary key,
NeighborhoodName varchar(50) not null,
ZipCode INT not null)
GO

CREATE TABLE tblSTOP_DIRECTION
(DirectionID INT IDENTITY(1,1) primary key,
DirectionName varchar(50) not null)
GO

CREATE TABLE tblSTOP
(StopID INT IDENTITY(1,1) primary key,
NeighborhoodID INT FOREIGN KEY REFERENCES tblNEIGHBORHOOD (NeighborhoodID) not null,
DirectionID INT FOREIGN KEY REFERENCES tblSTOP_DIRECTION (DirectionID) not null,
StopName varchar(50) not null)
GO

CREATE TABLE tblPASSENGER_TYPE
(PassengerTypeID INT IDENTITY(1,1) primary key,
PassengerTypeName varchar(50) not null)
GO

CREATE TABLE tblPASSENGER
(PassengerID INT IDENTITY(1,1) primary key,
PassengerTypeID INT FOREIGN KEY REFERENCES tblPASSENGER_TYPE (PassengerTypeID) not null,
PassengerFirstName varchar(50) not null,
PassengerLastName varchar(50) not null,
PassengerDOB Date not null,
PassengerEmail varchar(50) not null)
GO

CREATE TABLE tblBOARDING
(BoardingID INT IDENTITY(1,1) primary key,
TransportationID INT FOREIGN KEY REFERENCES tblTRANSPORTATION (TransportationID) not null,
PassengerID INT FOREIGN KEY REFERENCES tblPASSENGER (PassengerID) not null,
StopID INT FOREIGN KEY REFERENCES tblSTOP (StopID) not null)
GO

------------------------------------------------------------------ Sierra's Code ------------------------------------------------------------------------------
--------------- GetIDs needed for sproc 1 (Sierra)
Create Procedure GetDirectionID
@DirectionNamey varchar(50),
@Directiony INT OUTPUT
AS
SET @Directiony = (SELECT DirectionID FROM tblSTOP_DIRECTION WHERE DirectionName = @DirectionNamey)
GO

ALTER Procedure GetNeighborhoodID
@NeighborhoodNamey varchar(50),
@Zipy varchar(10),
@Neighborhoody INT OUTPUT
AS
SET @Neighborhoody = (SELECT NeighborhoodID FROM tblNEIGHBORHOOD WHERE NeighborhoodName = @NeighborhoodNamey AND ZipCode = @Zipy)
GO

--------------- GetIDs needed for sproc 2 (Sierra)
CREATE PROCEDURE GetVehicleID
@VName varchar(30),
@VID INT OUTPUT
AS
SET @VID = (SELECT vehicleID FROM tblVEHICLE
        WHERE VehicleName = @VName)
GO
SELECT DISTINCT vehicleName FROM tblVEHICLE

CREATE PROCEDURE GetEmployeeID
@EFirstName varchar(30),
@ELastName varchar(30),
@EDOB Date,
@Empy INT OUTPUT
AS
SET @Empy = (SELECT EmployeeID FROM tblEMPLOYEE WHERE EmployeeFirstName = @EFirstName AND
    EmployeeLastName = @ELastName AND EmployeeDOB = @EDOB)
GO

CREATE PROCEDURE GetTransportationID
@TranName varchar(30),
@TID INT OUTPUT
AS
SET @TID = (SELECT TransportationID FROM tblTRANSPORTATION WHERE transportationName = @TranName)
GO

CREATE PROCEDURE GetPassengerID
@Pemail varchar(50),
@Passengery INT OUTPUT
AS
SET @Passengery = (SELECT passengerID FROM tblPASSENGER WHERE PassengerEmail = @Pemail)
GO

CREATE PROCEDURE GetStopID
@SName varchar(30),
@SID INT OUTPUT
AS
SET @SID = (SELECT stopID FROM tblSTOP S
            WHERE S.stopName = @SName)
GO

------------------- sproc1----------- (Sierra)
CREATE PROCEDURE INSERT_STOP
@N_Name varchar(50),
@D_Name varchar(50),
@StopName varchar(50),
@ZIP varchar(10)
AS
DECLARE
@N_ID INT, @D_ID INT

EXEC GetNeighborhoodID
@NeighborhoodNamey = @N_Name,
@Zipy = @ZIP,
@Neighborhoody = @N_ID OUTPUT

IF @N_ID IS NULL
BEGIN
PRINT 'Neighborhood ID IS NULL'
RAISERROR ('CHECK NEIGHBORHOOD ID', 11, 1)
RETURN
END

EXEC GetDirectionID
@DirectionNamey = @D_Name,
@Directiony = @D_ID OUTPUT

IF @D_ID IS NULL
BEGIN
	PRINT 'Direction ID IS NULL'
	RAISERROR ('CHECK SPELLING OF Direction AS THERE IS AN ERROR', 11, 1)
	RETURN
END

BEGIN TRAN T1
INSERT INTO tblSTOP (NeighborhoodID, DirectionID, StopName)
VALUES (@N_ID, @D_ID, @StopName)
IF @@ERROR <> 0
 BEGIN
     ROLLBACK TRAN T1
 END
ELSE
 COMMIT TRAN T1
GO

---------------------------- sproc 2 ------------------ (Sierra)
CREATE PROCEDURE INSERT_BOARDING
@TranspName varchar(30),
@Pmail2 varchar(50),
@SN2 varchar(30)
AS
DECLARE
@T_ID INT, @P_ID INT, @S_ID INT

EXEC GetPassengerID
@Pemail = @Pmail2,
@Passengery = @P_ID OUTPUT
IF @P_ID IS NULL
BEGIN
PRINT 'passenger ID IS NULL'
RAISERROR ('CHECK passenger ID', 11, 1)
RETURN
END

EXEC GetStopID
@SName = @SN2,
@SID = @S_ID OUTPUT
IF @S_ID IS NULL
BEGIN
PRINT 'stop ID IS NULL'
RAISERROR ('CHECK stop ID', 11, 1)
RETURN
END

EXEC GetTransportationID
@TranName = @TranspName,
@TID =  @T_ID OUTPUT
IF @T_ID IS NULL
BEGIN
PRINT 'transportation ID IS NULL'
RAISERROR ('CHECK transportation ID', 11, 1)
RETURN
END

BEGIN TRAN T1
INSERT INTO tblBOARDING (TransportationID, PassengerID, StopID)
VALUES (@T_ID, @P_ID, @S_ID)
IF @@ERROR <> 0
 BEGIN
     ROLLBACK TRAN T1
 END
ELSE
 COMMIT TRAN T1
GO

----------------- synthetic transaction to populate tblBOARDING -------- (Sierra)
CREATE PROCEDURE Wrapper_INSERT_BOARDING
@RUN INT
AS
DECLARE @P_PK INT
DECLARE @S_PK INT
DECLARE @T_PK INT
DECLARE @P_COUNT INT = (SELECT COUNT(*) FROM tblPASSENGER)
DECLARE @S_COUNT INT = (SELECT COUNT(*) FROM tblSTOP)
DECLARE @T_COUNT INT = (SELECT COUNT(*) FROM tblTRANSPORTATION)
DECLARE @T_name varchar(30), @Pmail3 varchar(50), @SN3 varchar(30)

WHILE @RUN > 0
BEGIN

    SET @P_PK = (SELECT RAND() * @P_COUNT + 1)
    SET @Pmail3 = (SELECT PassengerEmail FROM tblPASSENGER WHERE PassengerID = @P_PK)

    SET @S_PK = (SELECT RAND() * @S_COUNT + 1 + 13624)
    SET @SN3 = (SELECT StopName FROM tblSTOP WHERE stopID = @S_PK)

    SET @T_PK = (SELECT RAND() * @T_COUNT + 1 + 8384)
    SET @T_name = (SELECT transportationName FROM tblTRANSPORTATION WHERE TransportationID = @T_PK)

EXEC INSERT_BOARDING
@TranspName = @T_name,
@Pmail2 = @Pmail3,
@SN2 = @SN3

SET @RUN = @RUN -1
END
GO

EXEC Wrapper_INSERT_BOARDING
    @RUN = 3000
    
----------------------- synthetic transaction to populate tblSTOP ----------- (Sierra)
CREATE PROCEDURE Wrapper_INSERT_STOP
@RUN INT
AS
DECLARE @N_PK INT
DECLARE @D_PK INT
DECLARE @S_PK INT
DECLARE @ZC varchar(10)
DECLARE @N_COUNT INT = (SELECT COUNT(*) FROM tblNEIGHBORHOOD)
DECLARE @D_COUNT INT = (SELECT COUNT(*) FROM tblSTOP_DIRECTION)
DECLARE @S_COUNT INT = (SELECT COUNT(*) FROM tblSTOP_DIRECTION)
DECLARE @NName varchar(30), @DName varchar(30), @SName varchar(30)

WHILE @RUN > 0
BEGIN

SET @N_PK = (SELECT RAND() * @N_COUNT + 1)
SET @NName = (SELECT NeighborhoodName FROM tblNEIGHBORHOOD WHERE NeighborhoodID = @N_PK)

SET @D_PK = (SELECT RAND() * @D_COUNT + 1)
SET @DName = (SELECT DirectionName FROM tblSTOP_DIRECTION WHERE DirectionID = @D_PK)

SET @S_PK = (SELECT RAND() * @S_COUNT + 1)
SET @SName = (SELECT OriginName FROM #tempStopName WHERE StopID = @S_PK)

SET @ZC = (SELECT ZipCode FROM tblNEIGHBORHOOD WHERE NeighborhoodID = @N_PK)

EXEC INSERT_STOP
@N_Name = @NName,
@D_Name  = @DName,
@StopName  = @SName,
@ZIP = @ZC

SET @RUN = @RUN -1

END
GO

EXEC Wrapper_INSERT_STOP 1000

--business rule 1 passengers cannot be under 10 and ride the bus in certain neighborhoods going south
CREATE FUNCTION dbo.proj01_underAge()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
    IF EXISTS(SELECT *
              FROM tblPASSENGER P
              JOIN tblBOARDING B ON P.PassengerID = B.PassengerID
              JOIN tblSTOP S ON S.StopID = B.StopID
              JOIN tblNEIGHBORHOOD N ON N.NeighborhoodID = S.NeighborhoodID
              JOIN tblSTOP_DIRECTION SD on S.DirectionID = SD.DirectionID
              WHERE P.PassengerDOB <= DATEADD(YEAR, -10, GETDATE())
                AND SD.DirectionName <> 'Southbound'
                AND N.NeighborhoodName <> 'Central Bronx'
                AND N.NeighborhoodName <> 'High Bridge and Morrisania')
              BEGIN
                SET @RET = 1
              end
    RETURN @RET
END
GO

ALTER TABLE tblPASSENGER with nocheck
ADD CONSTRAINT const_underAge
CHECK (dbo.proj01_underAge() = 0)

-- business rule 2 School buses cannot have any passengers over 22 and must have edu emails (Sierra)
CREATE FUNCTION dbo.proj01_maxPassengers()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INTEGER = 0
    IF EXISTS(SELECT * FROM tblBOARDING B
        JOIN tblPASSENGER P ON P.PassengerID = B.PassengerID
        JOIN tblTRANSPORTATION T on B.TransportationID = T.TransportationID
        JOIN tblVEHICLE V ON V.VehicleID = T.VehicleID
        JOIN tblVEHICLE_TYPE VT on V.VehicleTypeID = VT.VehicleTypeID
        WHERE P.PassengerDOB > DATEADD(YEAR, -22, GETDATE())
        AND VT.VehicleTypeName = 'School bus'
        AND P.PassengerEmail LIKE '%.edu')
        BEGIN
            SET @RET = 1
        END
    RETURN @RET
end
GO

ALTER TABLE tblBOARDING with nocheck
ADD CONSTRAINT const_maxBoarding
CHECK (dbo.proj01_maxPassengers() = 0)

-- computed column 1 Stop use frequency
CREATE FUNCTION fn_stopPop(@PK INT)
RETURNS varchar(30)
    AS
    BEGIN
    DECLARE @RET varchar(30) = (SELECT COUNT(B.BoardingID) as stopCount FROM tblBOARDING B
                                JOIN tblSTOP S ON S.StopID = B.StopID
                                WHERE S.StopID = @PK)
        RETURN @RET
    end
    GO

	ALTER TABLE tblSTOP
	ADD fn_stopPop
	AS (DBO.fn_stopPop(StopID))

-- computed column 2 number of stops in each direction (Sierra)
CREATE FUNCTION fn_DirectionPop(@PK varchar(30))
RETURNS varchar(30)
    AS
    BEGIN
    DECLARE @RET varchar(30) = (SELECT COUNT(S.stopID) FROM tblSTOP S
                                JOIN tblSTOP_DIRECTION SD on S.DirectionID = SD.DirectionID
                                WHERE SD.DirectionName = @PK)
        RETURN @RET
    end
    GO

	ALTER TABLE tblSTOP_DIRECTION
	ADD fn_TopNeighborhood
	AS (DBO.fn_DirectionPop(DirectionName))

-- View1 - ages and names of the youngest five percent of water taxi inspectors (Sierra)
CREATE VIEW vwYoungest_WaterTaxiInspectors
AS
SELECT A.EmployeeFirstName, A.EmployeeLastName, A.EmployeeAge FROM
       (SELECT NTILE(100) OVER (ORDER BY E.EmployeeDOB DESC) AS waterTaxiInspector,
        E.EmployeeFirstName, E.EmployeeLastName, E.EmployeeDOB, DATEDIFF(YEAR, E.EmployeeDOB, GETDATE()) AS EmployeeAge
FROM tblEMPLOYEE E
JOIN tblEMPLOYEE_TYPE ET on E.EmployeeTypeID = ET.EmployeeTypeID
WHERE ET.EmployeeTypeName = 'water taxi inspector') AS A
WHERE A.waterTaxiInspector <= 5
GO

-- View2 - top 3 oldest employees of each vehicle type (Sierra)
CREATE VIEW vwOldest_Employees_VType
AS
SELECT A.employeeFirstName, A.employeeLastName, A.EmployeeTypeName, A.EmployeeDOB FROM
                   (SELECT RANK() OVER (PARTITION BY ET.employeeTypeName ORDER BY E.EmployeeDOB)
                    AS oldEmps, E.employeeFirstName, E.employeeLastName, ET.EmployeeTypeName, E.EmployeeDOB
FROM tblEMPLOYEE E
    JOIN tblEMPLOYEE_TYPE ET on E.EmployeeTypeID = ET.EmployeeTypeID) as A
	WHERE oldEmps <= 3
GO

-- for presentation: (Sierra)
-- visualization 1
SELECT A.EmployeeFirstName, A.EmployeeLastName, A.EmployeeAge, A.EmployeeTypeName FROM
        (SELECT E.EmployeeFirstName, E.EmployeeLastName,
E.EmployeeDOB, DATEDIFF(YEAR, E.EmployeeDOB, GETDATE()) AS EmployeeAge, ET.EmployeeTypeName
FROM tblEMPLOYEE E
JOIN tblEMPLOYEE_TYPE ET on E.EmployeeTypeID = ET.EmployeeTypeID
WHERE ET.EmployeeTypeName = 'water taxi inspector') AS A

-- visualization 2
SELECT * FROM vwPassengerBoardingCount

--visualization 3
SELECT VT.VehicleTypeID, VT. VehicleTypeName, COUNT(B.boardingID) AS riderCount
FROM tblVEHICLE_TYPE VT
JOIN tblVEHICLE V ON VT.VehicleTypeID = V.VehicleTypeID
JOIN tblTRANSPORTATION TR ON V.VehicleID = TR.VehicleID
JOIN tblBOARDING B ON TR.TransportationID = B.TransportationID
GROUP BY VT.VehicleTypeID, VT.VehicleTypeName
GO

------------------------------------------------------------------ Justin's Code ------------------------------------------------------------------------------
-- Add vehicle type by Justin
INSERT INTO tblVEHICLE_TYPE(VehicleTypeName)
VALUES ('Coach/Motor coach'),
       ('School bus'),
       ('Shuttle bus'),
       ('Minibus'),
       ('Double-decker bus'),
       ('Single-decker bus'),
       ('Low-floor bus'),
       ('Guided bus'),
       ('Neighborhood bus'),
       ('Hybrid bus'),
       ('Open top bus');

-- Store procedure to get vehicle type ID by Justin
CREATE PROCEDURE GetVehicleTypeID @VTName varchar(50),
                                  @VeTy INT OUTPUT
AS
    SET @VeTy = (SELECT VehicleTypeID
                 FROM tblVEHICLE_TYPE
                 WHERE VehicleTypeName = @VTName)
GO

-- Store procedure to get route ID by Justin
CREATE PROCEDURE GetRouteID @RName varchar(50),
                            @Routy INT OUTPUT
AS
    SET @Routy = (SELECT RouteID
                  FROM tblROUTE
                  WHERE RouteName = @RName)
GO

-- Store procedure to insert vehicle by Justin
CREATE PROCEDURE InsertVehicle @VehicleTName varchar(50),
                              @VName varchar(50)
AS
DECLARE @VT_ID INT
    EXEC GetVehicleTypeID
         @VTName = @VehicleTName,
         @VeTy = @VT_ID OUTPUT
-- Error handling goes here
    IF @VT_ID IS NULL
        BEGIN
            PRINT 'Vehicle type name is null, please check!'
            RAISERROR ('@VT_ID is throwing an error, please check', 11, 1);
            RETURN
        END

    BEGIN TRAN T1
INSERT INTO tblVEHICLE(VehicleTypeID, VehicleName)
VALUES (@VT_ID, @VName)
    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRAN T1
        END
    ELSE
        COMMIT TRAN T1
GO

-- Synthetic transaction by Justin
CREATE PROCEDURE Wrapper_Insert_Vehicle
@RUN INT
AS
    DECLARE @VT_PK INT, @RandomDummy INT
    DECLARE @VehicleTypeCount INT = (SELECT COUNT(*) FROM tblVEHICLE_TYPE)
    DECLARE @WrapperVehicleTypeName varchar(50), @WrapperVehicleName varchar(50)
WHILE @RUN > 0
BEGIN
    SET @VT_PK = (SELECT RAND() * @VehicleTypeCount + 1)
    SET @WrapperVehicleTypeName = (SELECT VehicleTypeName FROM tblVEHICLE_TYPE WHERE VehicleTypeID = @VT_PK)
    SET @RandomDummy = (SELECT RAND() * 10000 + 1)
    SET @WrapperVehicleName = 'NYCT_' + (CONVERT(varchar(50), @RandomDummy))
    WHILE EXISTS(SELECT 1 FROM tblVEHICLE WHERE VehicleName = @WrapperVehicleName)
        BEGIN
            SET @RandomDummy = (SELECT RAND() * 10000 + 1)
            SET @WrapperVehicleName = 'NYCT_' + (CONVERT(varchar(50), @RandomDummy))
        END
    EXEC InsertVehicle
    @VehicleTName = @WrapperVehicleTypeName,
    @VName = @WrapperVehicleName

    SET @RUN = @RUN - 1
END

-- EXEC Wrapper_Insert_Vehicle
-- @RUN = 3000

-- Update vehicle Stored Procedure by Justin
CREATE PROCEDURE UpdateVehicle @VID INT,
                               @VTypename varchar(50)
AS
DECLARE @VT_ID INT
    EXEC GetVehicleTypeID
         @VTname = @VTypename,
         @VeTy = @VT_ID OUTPUT
-- Error handling goes here
    IF @VT_ID IS NULL
        BEGIN
            PRINT 'Vehicle type name is null, please check!'
            RAISERROR ('@VT_ID is throwing an error, please check', 11, 1);
            RETURN
        END

    BEGIN TRAN T1
UPDATE tblVEHICLE
SET VehicleTypeID = @VT_ID
WHERE VehicleID = @VID
    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRAN T1
        END
    ELSE
        COMMIT TRAN T1
GO

-- Business Rules by Justin
-- Rule1: Employees who are younger than 35 years old cannot be on the Route Name with 'B' and 'Q' by Justin
CREATE FUNCTION dbo.proj01_underageEmployeeforBandQRoute()
RETURNS INTEGER
AS
    BEGIN
        DECLARE @RET INT = 0
        IF EXISTS(SELECT * FROM tblEMPLOYEE E
            JOIN tblTRANSPORTATION TR ON E.EmployeeID = TR.EmployeeID
            JOIN tblROUTE R ON TR.RouteID = R.RouteID
            WHERE R.RouteName LIKE 'B%' OR R.RouteName LIKE 'O%'
            AND E.EmployeeDOB < DATEADD(YEAR, -35, GETDATE()))
        BEGIN
            SET @RET = 1
        END
        RETURN @RET
    END
GO

ALTER TABLE tblTRANSPORTATION WITH NOCHECK
ADD CONSTRAINT underageEmployeeforBandQRoute
CHECK (dbo.proj01_underageEmployeeforBandQRoute() = 0)

-- Rule2: No more than 5 Vehicles with type Double-decker bus in any neighborhood (VEHICLE) by Justin
CREATE FUNCTION dbo.proj01_nomore5VehiclesinAnyNeighborhood()
RETURNS INTEGER
AS
    BEGIN
        DECLARE @RET INT = 0
        IF EXISTS(SELECT COUNT(*) FROM tblVEHICLE V
            JOIN tblTRANSPORTATION TR ON V.VehicleID = TR.VehicleID
            JOIN tblVEHICLE_TYPE VT ON V.VehicleTypeID = VT.VehicleTypeID
            WHERE VT.VehicleTypeName = 'Double-decker bus'
            GROUP BY V.VehicleID
            HAVING COUNT(*) > 5)
        BEGIN
            SET @RET = 1
        END
        RETURN @RET
    END
GO

ALTER TABLE tblTRANSPORTATION WITH NOCHECK
ADD CONSTRAINT nomore5VehiclesinAnyNeighborhood
CHECK (dbo.proj01_nomore5VehiclesinAnyNeighborhood() = 0)

-- Computed Column
-- Column1: The number of vehicles of each vehicle type by Justin
CREATE FUNCTION fn_VehicleCount(@PK INT)
RETURNS INTEGER
AS
    BEGIN
        DECLARE @RET INT = (SELECT COUNT(*) FROM tblVEHICLE V
            JOIN tblVEHICLE_TYPE VT ON V.VehicleTypeID = VT.VehicleTypeID
            WHERE V.VehicleTypeID = @PK)
        RETURN @RET
    END
GO

ALTER TABLE tblVEHICLE_TYPE
ADD VehicleCount
AS (dbo.fn_VehicleCount(VehicleTypeID))

-- Column2: Average age of passengers in each transportation by Justin
CREATE FUNCTION fn_AveragePassengerAgeEachTransportation(@PK INT)
RETURNS INT
AS
    BEGIN
        DECLARE @RET INT = (SELECT AVG(DATEDIFF(YEAR, P.PassengerDOB, GETDATE()))
            FROM tblPASSENGER P
            JOIN tblBOARDING B ON P.PassengerID = B.PassengerID
            JOIN tblTRANSPORTATION TR ON B.TransportationID = TR.TransportationID
            WHERE TR.TransportationID = @PK
            GROUP BY P.PassengerID)
        RETURN @RET
    END
GO

ALTER TABLE tblTRANSPORTATION
ADD AveragePassengerAge
AS (dbo.fn_AveragePassengerAgeEachTransportation(TransportationID))

-- Views by Justin
-- View1: Label passengers who have taken Hybrid more than 1 time 'Environment Friendly
-- between 0 and 1 'Becoming Environment Friendly'
-- Others 'Traditional Riders' by Justin
CREATE VIEW vwPassengerBoardingCount
AS
    SELECT (CASE
        WHEN A.VehicleTypeName = 'Hybrid bus' AND HybridBoardingCount > 1
        THEN 'Environment Friendly'
        WHEN A.VehicleTypeName = 'Hybrid bus' AND HybridBoardingCount BETWEEN 0 AND 1
        THEN 'Becoming Environment Friendly'
        ELSE 'Traditional Riders'
        END) AS LabelsForPassengers, COUNT(*) AS NumberOfPassengers
FROM (
SELECT P.PassengerID, VT.VehicleTypeName, COUNT(B.BoardingID) AS HybridBoardingCount
FROM tblPASSENGER P
JOIN tblBOARDING B ON P.PassengerID = B.PassengerID
JOIN tblTRANSPORTATION TR ON B.TransportationID = TR.TransportationID
JOIN tblVEHICLE V ON TR.VehicleID = V.VehicleID
JOIN tblVEHICLE_TYPE VT ON V.VehicleTypeID = VT.VehicleTypeID
GROUP BY P.PassengerID, VT.VehicleTypeName) AS A

GROUP BY (CASE
        WHEN A.VehicleTypeName = 'Hybrid bus' AND HybridBoardingCount > 1
        THEN 'Environment Friendly'
        WHEN A.VehicleTypeName = 'Hybrid bus' AND HybridBoardingCount BETWEEN 0 AND 1
        THEN 'Becoming Environment Friendly'
        ELSE 'Traditional Riders'
        END)
GO

-- View2: rank vehicle types by Justin
CREATE VIEW vwMostPopularVehicleTypes
AS
    SELECT VT.VehicleTypeName,
           DENSE_RANK() OVER (ORDER BY (COUNT(B.BoardingID)) DESC) AS D_Rank,
           COUNT(B.BoardingID) AS BoardingCount
FROM tblVEHICLE_TYPE VT
JOIN tblVEHICLE V ON VT.VehicleTypeID = V.VehicleTypeID
JOIN tblTRANSPORTATION TR ON V.VehicleID = TR.VehicleID
JOIN tblBOARDING B ON TR.TransportationID = B.TransportationID
GROUP BY VT.VehicleTypeName
GO

--SHRUTI CODE

/* POPULATE TRANSPORTATION DATA RAW IF IT DOESN'T EXIST */
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_COPY_TransportationData')
	BEGIN
		DROP TABLE WORKING_COPY_TransportationData
		SELECT * 
		INTO WORKING_COPY_TransportationData
		FROM RAW_TransportationData
	END


/* POPULATE ROUTES FROM TRASPORTATION DATA*/
INSERT INTO tblROUTE(RouteName)
SELECT PublishedLineName
FROM WORKING_COPY_TransportationData
GROUP BY PublishedLineName

/* MAKE A WORKING COPY OF PEEPS FOR WHILE LOOP */
/* TBLEMPLOYEE IN PEEPS WAS EMPTY SO I POPULATED FROM CUSTOMERS INSTEAD */
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_PEEPS_Employees')
	BEGIN
		DROP TABLE WORKING_PEEPS_Employees

		SELECT TOP 7000 * 
		INTO WORKING_PEEPS_Employees
		FROM PEEPS.dbo.tblCustomer
		ORDER BY CustomerID DESC
	END


/* STORED PROCEDURE TO GET EMPLOYEE TYPE ID GIVEN THE EMPLOYEE TYPE NAME */
CREATE PROCEDURE getEmployeeTypeId_PROJ01 
@EmpTypeName varchar(50), 
@EmpTypeId INT OUTPUT
AS
SET @EmpTypeId = (Select EmployeeTypeID from tblEMPLOYEE_TYPE WHERE EmployeeTypeName = @EmpTypeName)
GO


-- BASE STORED PROCEDURE IN WRAPPER TO INSERT EMPLOYEES INTO TBLEMPLOYEE
CREATE PROCEDURE insertEmployee_Proj01
@Firsty varchar(50), 
@Lasty varchar(50), 
@EmpyDOB DATE, 
@ETypeName varchar(50)
AS 
DECLARE @TYPE_ID INT

	EXEC  getEmployeeTypeId_PROJ01 
	@EmpTypeName = @ETypeName, 
	@EmpTypeId = @TYPE_ID OUTPUT 

	IF @TYPE_ID IS NULL 
		BEGIN 
			PRINT 'Employee TYPE ID is NULL...time to terminate'
			RAISERROR ('Check spelling of EMPLOYEE TYPE ID as there is an error', 11, 1)
			RETURN
		END 

	BEGIN TRAN T1
		INSERT INTO tblEMPLOYEE(EmployeeTypeID, EmployeeFirstName, EmployeeLastName, EmployeeDOB)
			VALUES (@TYPE_ID, @FIRSTY, @LASTY, @EmpyDOB)

		IF @@ERROR <> 0 
			BEGIN 
				ROLLBACK TRAN T1 
			END
		ELSE 
			COMMIT TRAN T1
GO 


-- WRAPPER FOR INSERTING BATCH OF EMPLOYEES WITH A LOOP
CREATE PROCEDURE wrapperInsertEmployee
@RUN INT
AS
DECLARE @PEEP_EMP_PK INT
DECLARE @PEEP_EMP_COUNT INT = (SELECT COUNT(*) FROM WORKING_PEEPS_Employees)
DECLARE @ET_PK INT
DECLARE @ET_COUNT INT = (SELECT COUNT(*) FROM tblEMPLOYEE_TYPE)
DECLARE @FNAMEY varchar(50), @LNAMEY varchar(50), @EMPDOB DATE, 
@EmpyTypeName varchar(50)

WHILE @RUN > 0 
	BEGIN 
		SET @PEEP_EMP_PK = (SELECT MAX(CustomerID) FROM WORKING_PEEPS_Employees) 
		SET @ET_PK = (SELECT RAND() * @ET_COUNT + 1) 
		SET @EmpyTypeName = (SELECT EmployeeTypeName from tblEMPLOYEE_TYPE WHERE EmployeeTypeID = @ET_PK)
		SET @FNAMEY = (SELECT CustomerFName FROM WORKING_PEEPS_Employees WHERE CustomerID = @PEEP_EMP_PK)
		SET @LNAMEY = (SELECT CustomerLname FROM WORKING_PEEPS_Employees WHERE CustomerID = @PEEP_EMP_PK)
		SET @EMPDOB = (SELECT DateOfBirth FROM WORKING_PEEPS_Employees WHERE CustomerID = @PEEP_EMP_PK)


		EXEC insertEmployee_Proj01
		@Firsty = @FNAMEY, 
		@Lasty  = @LNAMEY, 
		@EmpyDOB = @EMPDOB, 
		@ETypeName = @EmpyTypeName

		DELETE 
		FROM WORKING_PEEPS_Employees
		WHERE CustomerID = @PEEP_EMP_PK

		SET @RUN = @RUN - 1
	END
GO

-- inserting 5000 employees
EXEC wrapperInsertEmployee 5000


/* Shruti second stored procedure... delete employee from table */
ALTER PROCEDURE deleteEmployee_Proj01
@Firsty varchar(50), 
@Lasty varchar(50), 
@EmpyDOB DATE, 
@ETypeName varchar(50)
AS 
	DECLARE @TYPE_ID INT

	EXEC getEmployeeTypeId_PROJ01 
	@EmpTypeName = @ETypeName, 
	@EmpTypeId = @TYPE_ID OUTPUT 

	IF @TYPE_ID IS NULL 
		BEGIN 
			PRINT 'Employee TYPE ID is NULL...time to terminate'
			RAISERROR ('Check spelling of EMPLOYEE TYPE ID as there is an error', 11, 1)
			RETURN
		END 

	BEGIN TRAN T1
		DELETE FROM tblEMPLOYEE
			WHERE EmployeeTypeID = @TYPE_ID AND
			EmployeeFirstName = @Firsty AND
			EmployeeLastName = @Lasty AND
			EmployeeDOB = @EmpyDOB

		IF @@ERROR <> 0 
			BEGIN 
				ROLLBACK TRAN T1 
			END
		ELSE 
			COMMIT TRAN T1
GO 


-- Shruti Business Rule 1
-- If Passenger age > 65 then Passenger type must be Senior
CREATE FUNCTION dbo.senior_passenger_type_proj01()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF EXISTS (SELECT * from tblPASSENGER P 
		JOIN tblPASSENGER_TYPE PT on P.PassengerTypeID = PT.PassengerTypeID
		WHERE PT.PassengerTypeName = 'Senior'
		AND P.PassengerDOB > DateAdd(YEAR, -65, getdate()))
		BEGIN
			SET @RET = 1
		END
	RETURN @RET
END 
GO

ALTER TABLE tblPassenger with nocheck
ADD CONSTRAINT senior_PassengerAge_check
CHECK (dbo.senior_passenger_type_proj01() = 0)
GO


-- Shruti Business Rule 2
-- If Passenger age < 18 then Passenger type must be minor
CREATE FUNCTION dbo.minor_passenger_type_proj01()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF EXISTS (SELECT * from tblPASSENGER P 
		JOIN tblPASSENGER_TYPE PT on P.PassengerTypeID = PT.PassengerTypeID
		WHERE PT.PassengerTypeName = 'Minor'
		AND P.PassengerDOB > DateAdd(YEAR, -18, getdate()))
		BEGIN
			SET @RET = 1
		END
	RETURN @RET
END 
GO

ALTER TABLE tblPassenger with nocheck
ADD CONSTRAINT minor_PassengerAge_check
CHECK (dbo.minor_passenger_type_proj01() = 0)
GO


-- Shruti Computed Column 1
-- Average age of employees
ALTER FUNCTION EmployeeType_AvgAge_Fn(@ETID INTEGER)
RETURNS NUMERIC (4, 1)
AS 
BEGIN
	DECLARE @RET NUMERIC = (SELECT AVG(DATEDIFF(YEAR, E.EmployeeDOB, GETDATE())) 
		FROM tblEMPLOYEE E
		JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
		WHERE ET.EmployeeTypeID = @ETID)
		
		RETURN @RET
END 
GO


ALTER TABLE tblEmployee_Type
ADD FN_PassType_AvgAge
AS (DBO.EmployeeType_AvgAge_Fn(EmployeeTypeID))


-- Shruti Computed Column 2: Number of transportations (aka rides) for each emloyee 
CREATE FUNCTION Num_Transportations_Emp_FN(@PK INTEGER)
RETURNS INTEGER 
AS 
BEGIN 
DECLARE @RET INTEGER = (SELECT COUNT(T.TransportationID) 
	FROM tblTRANSPORTATION T
	JOIN tblEMPLOYEE E on T.EmployeeID = E.EmployeeID
	WHERE E.EmployeeID = @PK)
	
	RETURN @RET
END 
GO 

ALTER TABLE tblEmployee
ADD Num_Transportations_Emp_FN
AS (DBO.Num_Transportations_Emp_FN(EmployeeID))
