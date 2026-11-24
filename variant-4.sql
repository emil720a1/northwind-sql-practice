USE northwind;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

INSERT INTO categories (CategoryID, CategoryName)
VALUES (9, 'Snacks');

SELECT CategoryID, CategoryName
FROM categories
WHERE CategoryID = 9;

COMMIT;

DESCRIBE shippers;

CREATE PROCEDURE AddShippers(
    IN p_id INT,
    IN p_company_name VARCHAR(40),
    IN p_phone VARCHAR(24)
)
INSERT INTO shippers (ShipperID, CompanyName, Phone)
VALUES (p_id, p_company_name, p_phone);

CALL AddShippers(10, 'New Shipper', '098999999');

SELECT
    ShipperID,
    CompanyName,
    Phone
FROM shippers
WHERE ShipperID = 10;


CREATE TABLE ShippersLog (
    ShipperID INT,
    CompanyName VARCHAR(40),
    Phone VARCHAR(24)
);

CREATE TRIGGER trg_shippers_log AFTER INSERT ON shippers
FOR EACH ROW
INSERT INTO ShippersLog (ShipperID, CompanyName, Phone)
VALUES (NEW.ShipperID, NEW.CompanyName, NEW.Phone);

CALL AddShippers(11, 'New Shipper2', '098999499');

SELECT * FROM shippers WHERE ShipperID = 11;

SELECT * FROM ShippersLog WHERE ShipperID = 11;

CREATE VIEW Show_Count AS
    SELECT
        cities.City,
        COALESCE(customers.CustomerCount, 0) AS CustomerCount,
        COALESCE(employees.EmployeeCount, 0) AS EmployeeCount
    FROM (
        SELECT City FROM customers
        UNION
        SELECT City FROM employees
    ) AS cities
    LEFT JOIN (
        SELECT City, COUNT(*) AS CustomerCount
        FROM customers
        GROUP BY City
    ) AS customers ON cities.City = customers.City
    LEFT JOIN (
        SELECT City, COUNT(*) AS EmployeeCount
        FROM employees
        GROUP BY City
    ) AS employees ON cities.City = employees.City;

SELECT * FROM Show_Count ORDER BY City;


CREATE USER 'BondarenkoOlehTCR31'@'localhost'
IDENTIFIED BY 'StudyPassword_2026!';

GRANT CREATE, INSERT, UPDATE, DELETE, SELECT
ON northwind.*
TO 'BondarenkoOlehTCR31'@'localhost';

SHOW GRANTS FOR 'BondarenkoOlehTCR31'@'localhost';

REVOKE CREATE
ON northwind.*
FROM 'BondarenkoOlehTCR31'@'localhost';

DROP USER 'BondarenkoOlehTCR31'@'localhost';

SELECT User, Host
FROM mysql.user
WHERE User LIKE 'Bondarenko%';