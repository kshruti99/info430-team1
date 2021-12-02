Use INFO_430_Proj_01

insert into tblPassenger_Type(PassengerTypeName)
values ('Minor'), ('Student'), ('Adult'), ('Senior')

select * from tblPassenger_Type

-- Populate neighborhood table
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_COPY_Neighborhoods')
	BEGIN
		DROP TABLE WORKING_COPY_Neighborhoods

		SELECT * 
		INTO WORKING_COPY_Neighborhoods
		FROM RAW_neighborhoodsData
	END

Select * from WORKING_COPY_Neighborhoods

Select * 
FRom RAW_neighborhoodsData

Select * 
INTO WORKING_COPY_Neighborhoods
FROM RAW_neighborhoodsData

ALTER TABLE tblNeighborhood
ADD ZipCode varchar(50) 

Select * from tblNeighborhood

Insert into tblNeighborhood(NeighborhoodName, ZipCode)
SELECT Neighborhood, ZipCode
FROM WORKING_COPY_Neighborhoods


CREATE PROCEDURE proj01_getPassengerTypeID 
@PTName varchar(50), 
@Passenger_Typey INT OUTPUT
AS
SET @Passenger_Typey = (Select PassengerTypeID from tblPassenger_Type WHERE PassengerTypeName = @PTName)



Select TOP 7000 * 
INTO WORKING_PEEPS_Customers
FROM PEEPS.dbo.tblCUSTOMER

Select * from WORKING_PEEPS_Customers

-- to make sure that we dont have this object already and repopulate it 
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_PEEPS_Customers')
	BEGIN
		DROP TABLE WORKING_PEEPS_Customers

		SELECT * 
		INTO WORKING_PEEPS_Customers
		FROM PEEPS.dbo.tblCUSTOMER
	END

	Select * from tblTransportation


-- Sproc 2: Update Passenger Information
Select * from tblPASSENGER


CREATE PROCEDURE proj01_updatePassenger
@P_ID INT,
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

BEGIN 
	UPDATE tblPASSENGER
		SET PassengerFirstName = @Firsty, 
		PassengerLastName = @Lasty, 
		PassengerDOB = @Birthy,
		PassengerEmail = @Emaily, 
		PassengerTypeID = @TYPY_ID
		WHERE PassengerID = @P_ID
	END
RETURN 0 

-- testing
exec proj01_updatePassenger
@P_ID = 1,
@Firsty = 'Kavie', 
@Lasty = ' Iyer', 
@Birthy = '11/03/1999', 
@Emaily = 'kavyee@uw.edu', 
@ptypeName = 'Student'

Select * from tblPASSENGER 
WHERE PassengerID = 1