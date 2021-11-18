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


