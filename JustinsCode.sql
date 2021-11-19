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
CREATE PROCEDURE InsertVehicle @VehicleTName varchar(50),
                               @RtName varchar(50)
AS
DECLARE @VT_ID INT, @R_ID INT
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

    EXEC GetRouteID
         @RName = @RtName,
         @Routy = @R_ID OUTPUT
-- Error handling goes here
    IF @R_ID IS NULL
        BEGIN
            PRINT 'Route name is null, please check!'
            RAISERROR ('@R_ID is throwing an error, please check', 11, 1);
        END

    BEGIN TRAN T1
INSERT INTO tblVEHICLE(VehicleTypeID, RouteID)
VALUES (@VT_ID, @R_ID)
    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRAN T1
        END
    ELSE
        COMMIT TRAN T1
GO

-- Synthetic transaction
CREATE PROCEDURE Wrapper_Insert_Vehicle
@RUN INT
AS
    DECLARE @VT_PK INT, @RT_PK INT
    DECLARE @VehicleTypeCount INT = (SELECT COUNT(*) FROM tblVEHICLE_TYPE)
    DECLARE @RouteCount INT = (SELECT COUNT(*) FROM tblROUTE)
    DECLARE @WrapperVehicleTypeName varchar(50), @WrapperRouteName varchar(50)
WHILE @RUN > 0
BEGIN
    SET @VT_PK = (SELECT RAND() * @VehicleTypeCount + 1)
    SET @WrapperVehicleTypeName = (SELECT VehicleTypeName FROM tblVEHICLE_TYPE WHERE VehicleTypeID = @VT_PK)

    SET @RT_PK = (SELECT RAND() * @RouteCount + 1)
    SET @WrapperRouteName = (SELECT RouteName FROM tblROUTE WHERE RouteID = @RT_PK)

    EXEC InsertVehicle
    @VehicleTName = @WrapperVehicleTypeName,
    @RtName = @WrapperRouteName

    SET @RUN = @RUN - 1
END

EXEC Wrapper_Insert_Vehicle
10

SELECT * FROM tblVEHICLE
