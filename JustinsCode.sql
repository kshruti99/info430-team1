Use INFO_430_Proj_01;

-- Add vehicle type
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

-- SELECT *
-- FROM tblVEHICLE_TYPE;

-- Store procedure to get vehicle type ID
CREATE PROCEDURE GetVehicleTypeID @VTName varchar(50),
                                  @VeTy INT OUTPUT
AS
    SET @VeTy = (SELECT VehicleTypeID
                 FROM tblVEHICLE_TYPE
                 WHERE VehicleTypeName = @VTName)
GO

-- Store procedure to get route ID
CREATE PROCEDURE GetRouteID @RName varchar(50),
                            @Routy INT OUTPUT
AS
    SET @Routy = (SELECT RouteID
                  FROM tblROUTE
                  WHERE RouteName = @RName)
GO

-- Store procedure to insert vehicle
ALTER PROCEDURE InsertVehicle @VehicleTName varchar(50),
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
INSERT INTO tblVEHICLE(VehicleTypeID, VehichleName)
VALUES (@VT_ID, @VName)
    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRAN T1
        END
    ELSE
        COMMIT TRAN T1
GO

-- Create vehicle name tempTable
CREATE TABLE #tempVehicleName
(VechileNameID INT IDENTITY(1, 1) PRIMARY KEY,
VehicleName varchar(50) NOT NULL)
GO
INSERT INTO #tempVehicleName(VehicleName)
SELECT VehicleRef FROM WORKING_COPY_TransportationData

-- Synthetic transaction
ALTER PROCEDURE Wrapper_Insert_Vehicle
@RUN INT
AS
    DECLARE @VT_PK INT, @VN_PK INT
    DECLARE @VehicleTypeCount INT = (SELECT COUNT(*) FROM tblVEHICLE_TYPE)
    DECLARE @VehicleNameCount INT = (SELECT COUNT(*) FROM #tempVehicleName)
    DECLARE @WrapperVehicleTypeName varchar(50), @WrapperVehicleName varchar(50)
WHILE @RUN > 0
BEGIN
    SET @VT_PK = (SELECT RAND() * @VehicleTypeCount + 1)
    SET @VN_PK = (SELECT RAND() * @VehicleNameCount + 1)
    SET @WrapperVehicleTypeName = (SELECT VehicleTypeName FROM tblVEHICLE_TYPE WHERE VehicleTypeID = @VT_PK)
    SET @WrapperVehicleName = (SELECT VehicleName FROM #tempVehicleName WHERE VechileNameID = @VN_PK)
    EXEC InsertVehicle
    @VehicleTName = @WrapperVehicleTypeName,
    @VName = @WrapperVehicleName

    SET @RUN = @RUN - 1
END

EXEC Wrapper_Insert_Vehicle
10

SELECT * FROM tblVEHICLE

ALTER TABLE tblTRANSPORTATION
ADD CONSTRAINT FK_TransportationVehicle
FOREIGN KEY (VehicleID) REFERENCES tblVEHICLE(VehicleID)

EXEC sp_rename 'dbo.tblVEHICLE.Vehicle', 'VehicleName', 'COLUMN';

