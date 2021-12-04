Use INFO_430_Proj_01;
-- getIDs needed for sproc 1
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

--sproc1
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

--GetIDs needed for sproc 2
CREATE PROCEDURE GetRouteID
@RName varchar(50),
@Routy INT OUTPUT
AS
SET @Routy = (SELECT RouteID
              FROM tblROUTE
              WHERE RouteName = @RName)
GO

CREATE PROCEDURE GetVehicleID
@VName varchar(30),
@VID INT OUTPUT
AS
SET @VID = (SELECT vehicleID FROM tblVEHICLE
        WHERE VehicleName = @VName)
GO

CREATE PROCEDURE GetEmployeeID
@EFirstName varchar(30),
@ELastName varchar(30),
@EDOB Date,
@Empy INT OUTPUT
AS
SET @Empy = (SELECT EmployeeID FROM tblEMPLOYEE WHERE EmployeeFirstName = @EFirstName AND
    EmployeeLastName = @ELastName AND EmployeeDOB = @EDOB)
GO

ALTER PROCEDURE GetTransportationID
@RouteN varchar(30),
@VehicleN varchar(30),
@EFName varchar(30),
@ELName varchar(30),
@EBday Date,
@TID INT OUTPUT
AS
DECLARE @RouteIdent INT, @VehicleIdent INT, @EmpID INT

EXEC GetVehicleID
@VName = @VehicleN,
@VID = @VehicleIdent OUTPUT

EXEC GetEmployeeID
@EFirstName = @EFName,
@ELastName = @ELName,
@EDOB = @EBday,
@Empy = @EmpID OUTPUT

EXEC GetRouteID
@RName = @RouteN,
@Routy = @RouteIdent OUTPUT

SET @TID = (SELECT transportationID FROM tblTRANSPORTATION
        WHERE RouteID = @RouteIdent AND VehicleID = @VehicleIdent
        AND EmployeeID = @EmpID)
GO





EXEC GetTransportationID
@RouteN = 'Bx28',
@VehicleN = 'Bus1',
@EFName = 'Jamila',
@ELName = 'Kyzar',
@EBday = '1959-04-12'




CREATE PROCEDURE GetPassengerID
@Pemail varchar(50),
@Passengery INT OUTPUT
AS
SET @Passengery = (SELECT passengerID FROM tblPASSENGER WHERE PassengerEmail = @Pemail)
GO

CREATE PROCEDURE GetNeighborhoodID
@NName varchar(50),
@ZCode INT,
@Neighy INT OUTPUT
AS
SET @Neighy = (SELECT neighborhoodID FROM tblNEIGHBORHOOD WHERE NeighborhoodName = @NName
                AND ZipCode = @ZCode)
GO

CREATE PROCEDURE GetStopID
@NeighName varchar(50),
@ZipC INT,
@Dname varchar(50),
@SID INT OUTPUT
AS
DECLARE @DID INT, @NeighborID INT

EXEC GetNeighborhoodID
@NName = @NeighName,
@ZCode = @ZipC,
@Neighy = @NeighborID OUTPUT

EXEC GetDirectionID
@DirectionNamey = @Dname,
@Directiony = @DID OUTPUT

SET @SID = (SELECT stopID FROM tblSTOP WHERE NeighborhoodID = @NeighborID AND DirectionID = @DID)
GO

--sproc 2
CREATE PROCEDURE INSERT_BOARDING
@RN2 varchar(30),
@VN2 varchar(30),
@EFN2 varchar(30),
@ELN2 varchar(30),
@EBD2 Date,
@Pmail2 varchar(50),
@NName2 varchar(50),
@zippy2 INT,
@DName2 varchar(30)
AS
DECLARE
@T_ID INT, @P_ID INT, @S_ID INT

EXEC GetTransportationID
@RouteN = @RN2,
@VehicleN = @VN2,
@EFName = @EFN2,
@ELName = @ELN2,
@EBday = @EBD2,
@TID =  @T_ID OUTPUT
IF @T_ID IS NULL
BEGIN
PRINT 'transportation ID IS NULL'
RAISERROR ('CHECK transportation ID', 11, 1)
RETURN
END

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
@NeighName = @NName2,
@ZipC = @zippy2,
@Dname = @DName2,
@SID = @S_ID OUTPUT
IF @S_ID IS NULL
BEGIN
PRINT 'stop ID IS NULL'
RAISERROR ('CHECK stop ID', 11, 1)
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

--business rule 1
-- passengers cannot be under 10 and ride the bus in certain neighborhoods going south
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

-- business rule 2
-- School buses cannot have any passengers over 22 and must have edu emails
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

-- computed column 1
-- Stop use frequency
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

-- computed column 2
-- number of stops in each direction
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

-- View1


-- View2
