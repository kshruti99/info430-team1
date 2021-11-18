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


