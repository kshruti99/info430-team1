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

SELECT COUNT(*) FROM tblEMPLOYEE