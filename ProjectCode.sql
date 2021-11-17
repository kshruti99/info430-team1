/*
starter SQL file to write all code in created in hay09

Each team member must code 2 of each of the following (8 objects per student):

1) Stored procedure
2) Check constraint
3) Computed column
4) Views

As stated in lecture, grading will be based on the student's ability to leverage complex skills presented in lecture and should include the following where appropriate:

* explicit transactions
* Complexity as appropriate: multiple JOINs, GROUP BY, ORDER BY, TOP, RANK, CROSS APPLY
* error-handling
* passing of appropriate  parameters (name values and/or output parameters)
* subqueries
* variables
*/

-- may need to double check nulls and not nulls
-- database name: INFO_430_Proj_01

CREATE TABLE tblEMPLOYEE_TYPE
(EmployeeTypeID INT IDENTITY(1,1) primary key,
EmployeeTypeName varchar(50) not null)
GO

CREATE TABLE tblEMPLOYEE
(EmployeeID INT IDENTITY(1,1) primary key,
EmployeeTypeID INT FOREIGN KEY REFERENCES tblEMPLOYEE_TYPE (EmployeeTypeID) not null,
EmployeeFirstName varchar(50) not null,
EmployeeLastName varchar(50) not null,
EmployeeDOB Date not null)
GO

CREATE TABLE tblROUTE
(RouteID INT IDENTITY(1,1) primary key,
RouteName varchar(50) not null)
GO

CREATE TABLE tblROUTE_EMPLOYEE
(Route_EmployeeID INT IDENTITY(1,1) primary key,
RouteID INT FOREIGN KEY REFERENCES tblROUTE (RouteID) not null,
EmployeeID INT FOREIGN KEY REFERENCES tblEMPLOYEE (EmployeeID) not null)
GO

CREATE TABLE tblVEHICLE_TYPE
(VehicleTypeID INT IDENTITY(1,1) primary key,
VehicleTypeName varchar(50) not null)
GO

CREATE TABLE tblVEHICLE
(VehicleID INT IDENTITY(1,1) primary key,
VehicleTypeID INT FOREIGN KEY REFERENCES tblVEHICLE_TYPE (VehicleTypeID) not null,
RouteID INT FOREIGN KEY REFERENCES tblROUTE (RouteID) not null)
GO

CREATE TABLE tblTRANSPORTATION
(TransportationID INT IDENTITY(1,1) primary key,
VehicleID INT FOREIGN KEY REFERENCES tblVEHICLE (VehicleID) not null,
RouteID INT FOREIGN KEY REFERENCES tblROUTE (RouteID) not null,
EmployeeID INT FOREIGN KEY REFERENCES tblEMPLOYEE (EmployeeID) not null)
GO

CREATE TABLE tblNEIGHBORHOOD
(NeighborhoodID INT IDENTITY(1,1) primary key,
NeighborhoodName varchar(50) not null)
GO

CREATE TABLE tblSTOP_DIRECTION
(DirectionID INT IDENTITY(1,1) primary key,
DirectionName varchar(50) not null)
GO

CREATE TABLE tblSTOP
(StopID INT IDENTITY(1,1) primary key,
NeighborhoodID INT FOREIGN KEY REFERENCES tblNEIGHBORHOOD (NeighborhoodID) not null,
StopTypeID INT FOREIGN KEY REFERENCES tblSTOP_TYPE (StopTypeID) not null,
StopName varchar(50) not null)
GO

CREATE TABLE tblPASSENGER_TYPE
(PassengerTypeID INT IDENTITY(1,1) primary key,
PassengerTypeName varchar(50) not null)
GO

CREATE TABLE tblPASSENGER
(PassengerID INT IDENTITY(1,1) primary key,
PassengerTypeID INT FOREIGN KEY REFERENCES tblPASSENGER_TYPE (PassengerTypeID) not null,
PassengerFirstName varchar(50) not null,
PassengerLastName varchar(50) not null,
PassengerDOB Date not null,
PassengerEmail varchar(50) not null)
GO

CREATE TABLE tblBOARDING
(BoardingID INT IDENTITY(1,1) primary key,
TransportationID INT FOREIGN KEY REFERENCES tblTRANSPORTATION (TransportationID) not null,
PassengerID INT FOREIGN KEY REFERENCES tblPASSENGER (PassengerID) not null,
StopID INT FOREIGN KEY REFERENCES tblSTOP (StopID) not null)
GO








