Use INFO_430_Proj_01;

-- Update vehicle Stored Procedure
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


-- ALTER TABLE tblVEHICLE
-- ADD VehicleName varchar(50) NOT NULL DEFAULT 'tbd'


-- Test
-- EXEC UpdateVehicle
-- @VID = 2,
--     @VTypename = 'Single-decker bus',
--     @RtName = 'M96';
-- SELECT * FROM tblVEHICLE WHERE VehicleID = 2;

-- Business Rules
-- Rule1: Employees who are younger than 35 years old cannot be on the Route Name with 'B' and 'Q'
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

-- Rule2: No more than 5 Vehicles with type Double-decker bus in any neighborhood (VEHICLE)
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
-- Column1: The number of vehicles of each vehicle type
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

-- Column2: Average age of passengers in each transportation
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

-- Views
-- View1:
CREATE VIEW vwPassengerBoardingCount
AS
    SELECT (CASE
        WHEN HybridBoardingCount > 500
        THEN 'Environment Friendly'
        WHEN HybridBoardingCount BETWEEN 200 AND 500
        THEN 'Becoming Environment Friendly'
        WHEN HybridBoardingCount BETWEEN 100 AND 200
        THEN 'Changing Mind'
        ELSE 'Traditional Riders'
        END) AS LabelsForPassengers, COUNT(*) AS NumberOfPassengers
FROM (
SELECT P.PassengerID, COUNT(B.BoardingID) AS HybridBoardingCount
FROM tblPASSENGER P
JOIN tblBOARDING B ON P.PassengerID = B.PassengerID
JOIN tblTRANSPORTATION TR ON B.TransportationID = TR.TransportationID
JOIN tblVEHICLE V ON TR.VehicleID = V.VehicleID
JOIN tblVEHICLE_TYPE VT ON V.VehicleTypeID = VT.VehicleTypeID
WHERE VT.VehicleTypeName = 'Hybrid bus'
GROUP BY P.PassengerID) AS A

GROUP BY (CASE
        WHEN HybridBoardingCount > 500
        THEN 'Environment Friendly'
        WHEN HybridBoardingCount BETWEEN 200 AND 500
        THEN 'Becoming Environment Friendly'
        WHEN HybridBoardingCount BETWEEN 100 AND 200
        THEN 'Changing Mind'
        ELSE 'Traditional Riders'
        END)
GO

-- View2:
CREATE VIEW vwMostPopularVehicleTypes
AS
    SELECT VT.VehicleTypeID, VT.VehicleTypeName,
           DENSE_RANK() OVER (ORDER BY (COUNT(B.BoardingID))) AS D_Rank
FROM tblVEHICLE_TYPE VT
JOIN tblVEHICLE V ON VT.VehicleTypeID = V.VehicleTypeID
JOIN tblTRANSPORTATION TR ON V.VehicleID = TR.VehicleID
JOIN tblBOARDING B ON TR.TransportationID = B.TransportationID
GROUP BY VT.VehicleTypeID, VT.VehicleTypeName
GO


