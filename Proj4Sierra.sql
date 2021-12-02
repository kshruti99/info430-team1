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

CREATE PROCEDURE GetVehicleTypeID
@VTName varchar(50),
@VeTy INT OUTPUT
AS
SET @VeTy = (SELECT VehicleTypeID
             FROM tblVEHICLE_TYPE
             WHERE VehicleTypeName = @VTName)
GO

CREATE PROCEDURE GetRouteID
@RName varchar(50),
@Routy INT OUTPUT
AS
SET @Routy = (SELECT RouteID
              FROM tblROUTE
              WHERE RouteName = @RName)
GO

CREATE PROCEDURE GetVehicleID
@VTN varchar(50),
@RN varchar(50),
@VTID INT,
@RID INT,
@VID INT OUTPUT
AS

EXEC GetVehicleTypeID
@VTName = @VTN,
@VeTy = @VTID OUTPUT

EXEC GetRouteID
@RName = @RN,
@Routy = @RID OUTPUT

SET @VID = (SELECT vehicleID FROM tblVEHICLE
        WHERE VehicleTypeID = @VTID AND RouteID = @RID)
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

CREATE PROCEDURE GetTransportationID
@VehicleTName varchar(50),
@RouteN varchar(30),
@VehicleTID INT,
@RouteIdent INT,
@VehicleIdent INT,
@EFName varchar(30),
@ELName varchar(30),
@EBday Date,
@EmpID INT,
@TID INT OUTPUT
AS

EXEC GetVehicleID
@VTN = @VehicleTName,
@RN = @RouteN,
@VTID = @VehicleTID,
@RID = @RouteIdent,
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
@NeighborID INT,
@Dname varchar(50),
@DID INT,
@SID INT OUTPUT
AS

EXEC GetNeighborhoodID
@NName = @NeighName,
@ZCOde = @ZipC,
@Neighy = @NeighborID OUTPUT

EXEC GetDirectionID
@DirectionNamey = @Dname,
@Directiony = @DID OUTPUT

SET @SID = (SELECT stopID FROM tblSTOP WHERE NeighborhoodID = @NeighborID AND DirectionID = @DID)
GO

--sproc 2
CREATE PROCEDURE INSERT_BOARDING
-- transportation ID, PassengerID, StopID
    -- transportation requires vehicle, route, and employee
    -- stop requires neighborhood, direction, stop name
@VTN2 varchar(50),
@RN2 varchar(30),
@VTID2 INT,
@RID2 INT,
@VID2 INT,
@EFN2 varchar(30),
@ELN2 varchar(30),
@EBD2 Date,
@EID2 INT,
@Pmail2 varchar(50),
@NName2 varchar(50),
@zippy2 INT,
@NID2 INT,
@DName2 varchar(30),
@DID2 INT
AS
DECLARE
@T_ID INT, @P_ID INT, @S_ID INT

EXEC GetTransportationID
@VehicleTName = @VTN2,
@RouteN = @RN2,
@VehicleTID = @VTID2,
@RouteIdent = @RID2,
@VehicleIdent = @VID2,
@EFName = @EFN2,
@ELName = @ELN2,
@EBday = @EBD2,
@EmpID = @EID2,
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
@NeighborID = @NID2,
@Dname = @DName2,
@DID = @DID2,
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
CREATE FUNCTION dbo.fn_underAge()
    RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INTEGER = 0
    IF EXISTS(SELECT *
              FROM tblPASSENGER P
              WHERE P.PassengerDOB <= 2)
        BEGIN
            SET @RET = 1
        end
    RETURN @RET
end
    ALTER TABLE tblPASSENGER
        ADD CONSTRAINT const_underAge
            CHECK (dbo.fn_underAge() = 0)

-- business rule 2
CREATE FUNCTION dbo.fn_maxPassengers()
    RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INTEGER = 0
    IF EXISTS(SELECT * FROM ___)
        BEGIN
            SET @RET = 1
        END
    RETURN @RET
end
    ALTER TABLE tblBOARDING
        ADD CONSTRAINT const_maxBoarding
            CHECK (dbo.fn_maxPassengers() = 0)

-- computed column 1
CREATE FUNCTION fn_stopPop(@PK INT)
RETURNS INT
    AS
    BEGIN
        DECLARE @RET INT = (SELECT MAX(COUNT(StopID)) FROM
            tblSTOP JOIN
                WHERE P.PassengerID = @PK)
        RETURN @RET
    end
    GO
ALTER TABLE tblPASSENGER
ADD ___ AS (dbo.fn_stopPop(PassengerID))



-- computed column 2