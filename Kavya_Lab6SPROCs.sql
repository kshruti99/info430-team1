/* Kavya Iyer
Lab 6
SPROC - Insert into Passenger*/

-- 1. Create Procedure for lookup table

USE INFO_430_Proj_01


CREATE PROCEDURE proj01_getPassengerTypeID 
@PTName varchar(50), 
@Passenger_Typey INT OUTPUT
AS
SET @Passenger_Typey = (Select PassengerTypeID from tblPassenger_Type WHERE PassengerTypeName = @PTName)


-- base stored proc
CREATE PROCEDURE insertPassenger
@Firsty varchar(50), 
@Lasty varchar(50), 
@Birthy DATE, 
@Emaily varchar(50), 
@ptypeName varchar(50)
AS 
DECLARE @TYPY_ID INT

EXEC  proj01_getPassengerTypeID 
@PTName = @ptypeName, 
@Passenger_Typey = @TYPY_ID OUTPUT 

-- error handling
IF @TYPY_ID IS NULL 
	BEGIN 
		PRINT 'PASSENGER TYPE ID IS NULL, PLEASE FIX'
		RAISERROR ('CHECK SPELLING OF PSNGR TYPE', 11, 1)
		RETURN
	END 

BEGIN TRAN T1
INSERT INTO TBLPASSENGER(PassengerTypeID, PassengerFirstName, PassengerLastName, PassengerDOB, 
						PassengerEmail)
	VALUES (@TYPY_ID, @FIRSTY, @LASTY, @BIRTHY, @EMAILY)

IF @@ERROR <> 0 
	BEGIN 
		ROLLBACK TRAN T1 
	END
ELSE 
	COMMIT TRAN T1
GO 


-- write wrapper 
CREATE PROCEDURE wrapper_insertPassenger
@RUN INT
AS
DECLARE @PT_PK INT
DECLARE @PT_COUNT INT = (SELECT COUNT(*) FROM TBLPASSENGER_TYPE)
DECLARE @PEEP_PK INT
DECLARE @PEEP_COUNT INT = (SELECT COUNT(*) FROM PEEPS.dbo.tblCUSTOMER)
DECLARE @FNAME varchar(50), @LNAME varchar(50), @DOBBY DATE, @PEMAIL varchar(50), 
@PASSTypName varchar(50)

WHILE @RUN > 0 
BEGIN 
SET @PT_PK = (SELECT RAND() * @PT_COUNT + 1) 
SET @PEEP_PK = (SELECT RAND () * @PEEP_COUNT + 1) 
SET @PASSTypName = (SELECT PassengerTypeName from tblPASSENGER_TYPE WHERE PassengerTypeID = @PT_PK)
SET @FNAME = (SELECT CustomerFName FROM PEEPS.dbo.tblCUSTOMER WHERE CustomerID = @PEEP_PK)
SET @LNAME = (SELECT CUSTOMERLNAME FROM PEEPS.dbo.tblCUSTOMER WHERE CustomerID = @PEEP_PK)
SET @DOBBY = (SELECT DATEOFBIRTH FROM PEEPS.dbo.tblCUSTOMER WHERE CustomerID = @PEEP_PK)
SET @PEMAIL = (SELECT EMAIL FROM PEEPS.dbo.tblCUSTOMER WHERE CustomerID = @PEEP_PK)


EXEC insertPassenger
@Firsty = @FNAME, 
@Lasty  = @LNAME, 
@Birthy = @DOBBY, 
@Emaily = @PEMAIL, 
@ptypeName = @PASSTYPNAME

set @run = @run - 1
END

EXEC wrapper_insertPassenger 1000

Select * from tblPASSENGER

