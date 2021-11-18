Use INFO_430_Proj_01

insert into tblSTOP_DIRECTION(DirectionName)
values ('Northbound'), ('Southbound'), ('Westbound'), ('Eastbound')

select * from tblPassenger_Type

Create Procedure GetDirectionID
@DirectionNamey varchar(50),
@Directiony INT OUTPUT
AS
SET @Directiony = (SELECT DirectionID FROM tblSTOP_DIRECTION WHERE DirectionName = @DirectionNamey)
GO

/*
Create Procedure GetStopID
@StopNamey varchar(50),
@Stopy INT OUTPUT
AS
SET @Stopy = (SELECT StopID FROM tblSTOP WHERE StopName = @StopNamey)
GO
*/

CREATE PROCEDURE INSERT_STOP
@N_Name varchar(50),
@D_Name varchar(50),
@StopName varchar(50)
AS
DECLARE
@N_ID INT, @D_ID INT

EXEC GetNeighborhoodID
@????? = @N_Name,
@????? = @N_ID OUTPUT

IF @N_ID IS NULL
BEGIN
PRINT 'Neighborhood ID IS NULL'
RAISERROR ('CHECK CUST ID', 11, 1)
RETURN
END

EXEC GetDirectionID
@????? = @D_Name,
@????? = @D_ID OUTPUT

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
