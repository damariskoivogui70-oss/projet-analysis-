use microfinance_db;
select * from microfinance_data;

-- A. select distinct values on any of the fields on you table

select distinct paymentStatus
from microfinance_data;

select distinct Gender
from microfinance_data;

select distinct LoanID
from microfinance_data;

select distinct ClientName
from microfinance_data;

select distinct paymentStatus
from microfinance_data;

-- Create function on the table
CREATE FUNCTION TotalRepayment(amount DECIMAL(10,2), rate DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN amount + (amount * rate / 100);

CREATE TABLE loan_log (
  LogID INT NOT NULL AUTO_INCREMENT,
  LoanID VARCHAR(50),
  ActionType VARCHAR(20),
  ActionDate DATETIME,
  PRIMARY KEY (LogID)
);
-- c. Create Insert, Delete and Update triggers on your table.
DELIMITER $$

CREATE TRIGGER after_loan_insert
AFTER INSERT ON microfinance_data
FOR EACH ROW
BEGIN
    INSERT INTO loan_log (LoanID, ActionType, ActionDate)
    VALUES (NEW.LoanID, 'INSERT', NOW());
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_loan_update
AFTER UPDATE ON microfinance_data
FOR EACH ROW
BEGIN
    INSERT INTO loan_log (LoanID, ActionType, ActionDate)
    VALUES (NEW.LoanID, 'UPDATE', NOW());
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER after_loan_delete
AFTER DELETE ON microfinance_data
FOR EACH ROW
BEGIN
    INSERT INTO loan_log (LoanID, ActionType, ActionDate)
    VALUES (OLD.LoanID, 'DELETE', NOW());
END$$

DELIMITER ;

Show triggers;

-- d. Create stored procedures. 

DELIMITER $$

DROP PROCEDURE IF EXISTS AddNewLoan$$

CREATE PROCEDURE AddNewLoan(
  IN p_LoanID VARCHAR(10),
  IN p_ClientName VARCHAR(100),
  IN p_Gender VARCHAR(10),
  IN p_LoanAmount DECIMAL(10,2),
  IN p_InterestRate DECIMAL(5,2),
  IN p_DurationMonths INT,
  IN p_PaymentStatus VARCHAR(20),
  IN p_LoanDate DATE
)
BEGIN
  INSERT INTO microfinance_data(
    LoanID,ClientName, Gender,LoanAmount,InterestRate,DurationMonths,PaymentStatus,LoanDate)
  VALUES
    (p_LoanID, p_ClientNama, p_Gender, p_LoanAmount, p_InterestRate, p_DurationMonths, p_PaymentStatus, p_LoanDate);
END$$

DELIMITER ;
CALL AddNewLoan('Marie Diallo', 50000, 10, '2025-10-10');
SELECT * FROM microfinance_data;
-- E Add a new field to the table. 
alter table microfinance_data
add column LoanStatus VARCHAR(20) default 'Pending';

alter table microfinance_data
add column paymentDate Date;
-- verifier le changement
DESCRIBE microfinance_data;

-- F. Change the name of a field on your table. 

alter table microfinance_data
change column ClientName CustomerName VARCHAR(100);

describe microfinance_data;

-- G. Create a new user in your database

create user 'microfinance_user'@'localhost'
identified by 'StrongPassword123';

GRANT ALL PRIVILEGES ON microfinance_db.*
TO 'microfinance_user'@'localhost';
FLUSH PRIVILEGES;
select user, Host from mysql.user;

-- Grant the new user select, insert and alter privileges. 
grant select, insert, alter
on microfinance_db.*
to 'microfinance_user'@'localhost';
flush privileges;
-- verifier le privilege de l'utilisateur
show grants for
'microfinance_user'@'localhost';
-- Create three related tables, and write a Left Join, Right Join, and Inner Join Statements on the tables.

-- Table 1 : Clients
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY AUTO_INCREMENT,
    ClientName VARCHAR(100),
    Gender VARCHAR(10),
    City VARCHAR(50)
);

-- Table 2 : Loans (prêts)
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY AUTO_INCREMENT,
    ClientID INT,
    LoanAmount DECIMAL(10,2),
    InterestRate DECIMAL(5,2),
    LoanDate DATE,
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID)
);

-- Table 3 : Payments 
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    LoanID INT,
    PaymentDate DATE,
    AmountPaid DECIMAL(10,2),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
);

INSERT INTO Clients (ClientName, Gender, City) VALUES
('Marie Diallo', 'Female', 'Conakry'),
('Ibrahima Bah', 'Male', 'Labé'),
('Aissatou Keita', 'Female', 'Kindia');

INSERT INTO Loans (ClientID, LoanAmount, InterestRate, LoanDate) VALUES
(1, 50000, 10.5, '2025-01-01'),
(2, 80000, 12.0, '2025-02-15'),
(3, 60000, 9.5, '2025-03-10');

INSERT INTO Payments (LoanID, PaymentDate, AmountPaid) VALUES
(1, '2025-04-01', 10000),
(1, '2025-05-01', 15000),
(2, '2025-05-04', 20000);
DESCRIBE PAYMENTS;
 SHOW CREATE TABLE Payments;
  -- INNER JOIN
  SELECT 
    clients.ClientName, 
    loans.LoanAmount, 
    payments.AmountPaid, 
    payments.PaymentDate
FROM clients
INNER JOIN loans ON clients.ClientID = loans.ClientID
INNER JOIN payments ON loans.LoanID = payments.LoanID;
-- LEFT JOIN
SELECT 
    clients.ClientName, 
    loans.LoanAmount, 
    payments.AmountPaid
FROM clients
LEFT JOIN loans ON clients.ClientID = loans.ClientID
LEFT JOIN payments ON loans.LoanID = payments.LoanID;

-- RIGHT JOIN
SELECT 
    clients.ClientName, 
    loans.LoanAmount, 
    payments.AmountPaid
FROM clients
RIGHT JOIN loans ON clients.ClientID = loans.ClientID
RIGHT JOIN payments ON loans.LoanID = payments.LoanID;

INSERT INTO clients (ClientName, Gender, City)
values ('kadiatou','Female','Boké');

SELECT 
    clients.ClientName, 
    loans.LoanAmount, 
    payments.AmountPaid
FROM clients
LEFT JOIN loans ON clients.ClientID = loans.ClientID
LEFT JOIN payments ON loans.LoanID = payments.LoanID;
-- I Write SQL statements to backup and restore your database. (sauvergarde la base de donnée)

select user(), current_user();

-- 2.A. What is the difference between CHAR and VARCHAR datatypes?
-- CHAR vs VARCHAR in MySQL

-- CHAR is a fixed-length data type, while VARCHAR is variable-length.
-- When we define CHAR(5) and insert 'AB', MySQL stores it as 'AB   ' (with spaces),
-- but VARCHAR(5) stores it as 'AB'. Hence, CHAR always uses the full length,
-- while VARCHAR only uses the space needed for the actual characters.

-- Example:
CREATE TABLE test_char_varchar (
  code CHAR(5),
  name VARCHAR(5)
);

INSERT INTO test_char_varchar (code, name)
VALUES ('AB', 'AB');

SELECT code, name, LENGTH(code) AS len_code, LENGTH(name) AS len_name
FROM test_char_varchar; 

-- 2.C . Create an ERD with 6 related tables. 
-- ANSWER: The ERD (Entity Relationship Diagram) shows how tables in the database are related.
-- In this microfinance system:
-- One customer can have many loans.
-- One loan can have many payments. Below are the SQL commands used to create the related tables.
-- After creating them, you can generate the ERD by:
-- Database → Reverse Engineer → Select your database → Finish.
-- The ERD will show all relationships automatically.

CREATE TABLE customers (
  CustomerID INT PRIMARY KEY AUTO_INCREMENT,
  CustomerName VARCHAR(100),
  Address VARCHAR(255),
  Phone VARCHAR(20)
);

CREATE TABLE loans (
  LoanID INT PRIMARY KEY AUTO_INCREMENT,
  CustomerID INT,
  LoanAmount DECIMAL(10,2),
  InterestRate DECIMAL(5,2),
  StartDate DATE,
  FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);

CREATE TABLE payments (
  PaymentID INT PRIMARY KEY AUTO_INCREMENT,
  LoanID INT,
  PaymentDate DATE,
  AmountPaid DECIMAL(10,2),
  FOREIGN KEY (LoanID) REFERENCES loans(LoanID)
);

--  What is the difference between SQL and MySQL?
-- SQL (Structured Query Language) is a standard language used to manage and manipulate databases.
-- It provides commands such as SELECT, INSERT, UPDATE, DELETE, and CREATE.
-- MySQL is a database management system (DBMS) that uses SQL to interact with its databases.
-- In other words:
--  SQL is the language.
-- MySQL is the software (system) that uses SQL.
-- eg:SQL command → SELECT * FROM customers;  MySQL executes that command to retrieve data from the 'customers' table.



 


