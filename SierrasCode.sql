Use INFO_430_Proj_01;

insert into tblSTOP_DIRECTION(DirectionName)
values ('Northbound'), ('Southbound'), ('Westbound'), ('Eastbound')

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

CREATE TABLE #tempStopName
(StopID INT IDENTITY(1,1) primary key,
OriginName varchar(50) not null)
GO
INSERT INTO #tempStopName(OriginName)
SELECT OriginName FROM WORKING_COPY_TransportationData

-- synthetic transaction
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
--should i just start at one?
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
