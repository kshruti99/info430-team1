Use INFO_430_Proj_01;

-- Update vehicle Stored Procedure
CREATE PROCEDURE UpdateVehicle @VID INT,
                               @VTypename varchar(50),
                               @RtName varchar(50)
AS
DECLARE @VT_ID INT, @Rt_ID INT
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

    EXEC GetRouteID
         @RName = @RtName,
         @Routy = @Rt_ID OUTPUT
-- Error handling goes here
    IF @Rt_ID IS NULL
        BEGIN
            PRINT 'Route name is null, please check!'
            RAISERROR ('@Rt_ID is throwing an error, please check', 11, 1);
            RETURN
        END

    BEGIN TRAN T1
UPDATE tblVEHICLE
SET VehicleTypeID = @VT_ID,
    RouteID       = @Rt_ID
WHERE VehicleID = @VID
    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRAN T1
        END
    ELSE
        COMMIT TRAN T1
GO

-- SELECT * FROM tblROUTE;
-- Test
-- EXEC UpdateVehicle
-- @VID = 2,
--     @VTypename = 'Single-decker bus',
--     @RtName = 'M96';
-- SELECT * FROM tblVEHICLE WHERE VehicleID = 2;

-- Business Rules
-- Rule1:
-- Rule2:
