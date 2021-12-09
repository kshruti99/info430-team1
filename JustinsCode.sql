Use INFO_430_Proj_01;

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
