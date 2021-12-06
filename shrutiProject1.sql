USE INFO_430_Proj_01

/* POPULATE TRANSPORTATION DATA RAW IF IT DOESN'T EXIST */
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_COPY_TransportationData')
	BEGIN
		DROP TABLE WORKING_COPY_TransportationData
		SELECT * 
		INTO WORKING_COPY_TransportationData
		FROM RAW_TransportationData
	END


/* POPULATE ROUTES FROM TRASPORTATION DATA*/
INSERT INTO tblROUTE(RouteName)
SELECT PublishedLineName
FROM WORKING_COPY_TransportationData
GROUP BY PublishedLineName

/* MAKE A WORKING COPY OF PEEPS FOR WHILE LOOP */
/* TBLEMPLOYEE IN PEEPS WAS EMPTY SO I POPULATED FROM CUSTOMERS INSTEAD */
IF EXISTS (SELECT * FROM sys.sysobjects WHERE Name = 'WORKING_PEEPS_Employees')
	BEGIN
		DROP TABLE WORKING_PEEPS_Employees

		SELECT TOP 7000 * 
		INTO WORKING_PEEPS_Employees
		FROM PEEPS.dbo.tblCustomer
		ORDER BY CustomerID DESC
	END


/* STORED PROCEDURE TO GET EMPLOYEE TYPE ID GIVEN THE EMPLOYEE TYPE NAME */
CREATE PROCEDURE getEmployeeTypeId_PROJ01 
@EmpTypeName varchar(50), 
@EmpTypeId INT OUTPUT
AS
SET @EmpTypeId = (Select EmployeeTypeID from tblEMPLOYEE_TYPE WHERE EmployeeTypeName = @EmpTypeName)
GO


-- BASE STORED PROCEDURE IN WRAPPER TO INSERT EMPLOYEES INTO TBLEMPLOYEE
CREATE PROCEDURE insertEmployee_Proj01
@Firsty varchar(50), 
@Lasty varchar(50), 
@EmpyDOB DATE, 
@ETypeName varchar(50)
AS 
DECLARE @TYPE_ID INT

	EXEC  getEmployeeTypeId_PROJ01 
	@EmpTypeName = @ETypeName, 
	@EmpTypeId = @TYPE_ID OUTPUT 

	IF @TYPE_ID IS NULL 
		BEGIN 
			PRINT 'Employee TYPE ID is NULL...time to terminate'
			RAISERROR ('Check spelling of EMPLOYEE TYPE ID as there is an error', 11, 1)
			RETURN
		END 

	BEGIN TRAN T1
		INSERT INTO tblEMPLOYEE(EmployeeTypeID, EmployeeFirstName, EmployeeLastName, EmployeeDOB)
			VALUES (@TYPE_ID, @FIRSTY, @LASTY, @EmpyDOB)

		IF @@ERROR <> 0 
			BEGIN 
				ROLLBACK TRAN T1 
			END
		ELSE 
			COMMIT TRAN T1
GO 


-- WRAPPER FOR INSERTING BATCH OF EMPLOYEES WITH A LOOP
CREATE PROCEDURE wrapperInsertEmployee
@RUN INT
AS
DECLARE @PEEP_EMP_PK INT
DECLARE @PEEP_EMP_COUNT INT = (SELECT COUNT(*) FROM WORKING_PEEPS_Employees)
DECLARE @ET_PK INT
DECLARE @ET_COUNT INT = (SELECT COUNT(*) FROM tblEMPLOYEE_TYPE)
DECLARE @FNAMEY varchar(50), @LNAMEY varchar(50), @EMPDOB DATE, 
@EmpyTypeName varchar(50)

WHILE @RUN > 0 
	BEGIN 
		SET @PEEP_EMP_PK = (SELECT MAX(CustomerID) FROM WORKING_PEEPS_Employees) 
		SET @ET_PK = (SELECT RAND() * @ET_COUNT + 1) 
		SET @EmpyTypeName = (SELECT EmployeeTypeName from tblEMPLOYEE_TYPE WHERE EmployeeTypeID = @ET_PK)
		SET @FNAMEY = (SELECT CustomerFName FROM WORKING_PEEPS_Employees WHERE CustomerID = @PEEP_EMP_PK)
		SET @LNAMEY = (SELECT CustomerLname FROM WORKING_PEEPS_Employees WHERE CustomerID = @PEEP_EMP_PK)
		SET @EMPDOB = (SELECT DateOfBirth FROM WORKING_PEEPS_Employees WHERE CustomerID = @PEEP_EMP_PK)


		EXEC insertEmployee_Proj01
		@Firsty = @FNAMEY, 
		@Lasty  = @LNAMEY, 
		@EmpyDOB = @EMPDOB, 
		@ETypeName = @EmpyTypeName

		DELETE 
		FROM WORKING_PEEPS_Employees
		WHERE CustomerID = @PEEP_EMP_PK

		SET @RUN = @RUN - 1
	END
GO

EXEC wrapperInsertEmployee 5000


/* Shruti second stored procedure... delete employee from table */

ALTER PROCEDURE deleteEmployee_Proj01
@Firsty varchar(50), 
@Lasty varchar(50), 
@EmpyDOB DATE, 
@ETypeName varchar(50)
AS 
	DECLARE @TYPE_ID INT

	EXEC getEmployeeTypeId_PROJ01 
	@EmpTypeName = @ETypeName, 
	@EmpTypeId = @TYPE_ID OUTPUT 

	IF @TYPE_ID IS NULL 
		BEGIN 
			PRINT 'Employee TYPE ID is NULL...time to terminate'
			RAISERROR ('Check spelling of EMPLOYEE TYPE ID as there is an error', 11, 1)
			RETURN
		END 

	BEGIN TRAN T1
		DELETE FROM tblEMPLOYEE
			WHERE EmployeeTypeID = @TYPE_ID AND
			EmployeeFirstName = @Firsty AND
			EmployeeLastName = @Lasty AND
			EmployeeDOB = @EmpyDOB

		IF @@ERROR <> 0 
			BEGIN 
				ROLLBACK TRAN T1 
			END
		ELSE 
			COMMIT TRAN T1
GO 

SELECT * from tblEMPLOYEE E
JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
ORDER BY EmployeeID DESC

EXEC insertEmployee_Proj01
@Firsty = 'Tam',
@Lasty = 'Vangemert',
@EmpyDOB = '2099-12-01',
@ETypeName = 'Bus Driver'



-- Shruti Business Rule 1
-- If Passenger age > 65 then Passenger type = Senior (PASSENGER
CREATE FUNCTION dbo.senior_passenger_type_proj01()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF EXISTS (SELECT * from tblPASSENGER P 
		JOIN tblPASSENGER_TYPE PT on P.PassengerTypeID = PT.PassengerTypeID
		WHERE PT.PassengerTypeName = 'Senior'
		AND P.PassengerDOB > DateAdd(YEAR, -65, getdate()))
		BEGIN
			SET @RET = 1
		END
	RETURN @RET
END 
GO

ALTER TABLE tblPassenger with nocheck
ADD CONSTRAINT senior_PassengerAge_check
CHECK (dbo.senior_passenger_type_proj01() = 0)
GO


-- Shruti Business Rule 1
-- If Passenger age > 65 then Passenger type = Senior (PASSENGER
CREATE FUNCTION dbo.minor_passenger_type_proj01()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
	IF EXISTS (SELECT * from tblPASSENGER P 
		JOIN tblPASSENGER_TYPE PT on P.PassengerTypeID = PT.PassengerTypeID
		WHERE PT.PassengerTypeName = 'Minor'
		AND P.PassengerDOB > DateAdd(YEAR, -18, getdate()))
		BEGIN
			SET @RET = 1
		END
	RETURN @RET
END 
GO

ALTER TABLE tblPassenger with nocheck
ADD CONSTRAINT minor_PassengerAge_check
CHECK (dbo.minor_passenger_type_proj01() = 0)
GO


-- Shruti Computed Column 1
-- Average age of employees
CREATE FUNCTION EmployeeType_AvgAge_Fn(@ETID INTEGER)
RETURNS NUMERIC (4, 1)
AS 
BEGIN
	DECLARE @RET NUMERIC = (SELECT AVG(DATEDIFF(YEAR, E.EmployeeDOB, GETDATE())) 
		FROM tblEMPLOYEE E
		JOIN tblEMPLOYEE_TYPE ET ON E.EmployeeTypeID = ET.EmployeeTypeID
		WHERE ET.EmployeeTypeID = @ETID)
		
		RETURN @RET
END 
GO


ALTER TABLE tblEmployeeType
ADD FN_PassType_AvgAge
AS (DBO.EmployeeType_AvgAge_Fn(EmployeeTypeID))


-- Computed Column 2: Number of transportations (aka rides) for each emloyee 
CREATE FUNCTION Num_Transportations_Emp_FN(@PK INTEGER)
RETURNS INTEGER 
AS 
BEGIN 
DECLARE @RET INTEGER = (SELECT COUNT(T.TransportationID) 
	FROM tblTRANSPORTATION T
	JOIN tblEMPLOYEE E on T.EmployeeID = E.EmployeeID
	WHERE E.EmployeeID = @PK)
	
	RETURN @RET
END 
GO 

ALTER TABLE tblEmployee
ADD Num_Transportations_Emp_FN
AS (DBO.Num_Transportations_Emp_FN(EmployeeID))