Use INFO_430_Proj_01;

---------------------------------------------------- Sierra's Code -------------------------------------------------------------
--------------- GetIDs needed for sproc 1
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

--------------- GetIDs needed for sproc 2
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

------------------- sproc1----------- 
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

---------------------------- sproc 2 ------------------
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

--synthetic transaction to populate tblBOARDING
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

-- business rule 2 School buses cannot have any passengers over 22 and must have edu emails
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

-- computed column 2 number of stops in each direction
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

-- View1 - ages and names of the youngest five percent of water taxi inspectors
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

-- View2 - top 3 oldest employees of each vehicle type
CREATE VIEW vwOldest_Employees_VType
AS
SELECT A.employeeFirstName, A.employeeLastName, A.EmployeeTypeName, A.EmployeeDOB FROM
                   (SELECT RANK() OVER (PARTITION BY ET.employeeTypeName ORDER BY E.EmployeeDOB)
                    AS oldEmps, E.employeeFirstName, E.employeeLastName, ET.EmployeeTypeName, E.EmployeeDOB
FROM tblEMPLOYEE E
    JOIN tblEMPLOYEE_TYPE ET on E.EmployeeTypeID = ET.EmployeeTypeID) as A
	WHERE oldEmps <= 3
GO

-- for presentation:
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
