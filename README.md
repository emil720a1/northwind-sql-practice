# Northwind SQL Practice

**Variant 4 · MySQL · Relational database queries**

This project explores the Northwind sample database through SQL queries and database administration exercises. It covers filtering, aggregation, joins, transactions, stored procedures, triggers, views, and user privileges.

## Objective

Practice extracting and combining business data from a relational database: orders, customers, employees, shippers, products, categories, and suppliers.

## Skills demonstrated

- Filtering dates and text with `DAY()` and `LIKE`.
- Summarizing data with `COUNT()`, `SUM()`, and `GROUP BY`.
- Combining datasets with `LEFT JOIN` and `UNION`.
- Handling missing values with `COALESCE()` and rounding with `ROUND()`.
- Using a correlated subquery and finding common values with `INTERSECT`.

## Files

- `MY_SQL Labwork2.sql` — a MySQL dump used to create and populate the `northwind` database.
- `variant-4.sql` — the SQL script for practical assignment 2.1, variant 4.
- `Northwind_PR1_2_Variant4.sln` — the JetBrains Rider solution.

## Getting started

1. Connect Rider to a MySQL server that supports `INTERSECT` (MySQL 8.0.31 or newer).
2. Import the dump if you do not already have the Northwind database. The dump contains `DROP TABLE IF EXISTS` statements, so importing it can replace existing tables in `northwind`.
3. Open `variant-4.sql` and select the `northwind` database connection. Run the statements for each exercise in order, rather than executing the whole file at once.

## Exercises

1. Find orders placed on the first day of a month.
2. Find customers whose postal code starts with `10`.
3. Count customers by country.
4. Count customers and employees by city.
5. Calculate total freight by shipping company, rounded to a whole number.
6. List products and their categories using a subquery.
7. Find countries with both customers and suppliers using a set operation.

## Queries

Select the database before running the queries:

```sql
USE northwind;
```

### 1. Orders placed on the first day of a month

Find orders placed on day 1, regardless of month or year.

```sql
SELECT OrderID, CustomerID, OrderDate
FROM orders
WHERE DAY(OrderDate) = 1;
```

### 2. Customers whose postal code starts with 10

Use a prefix pattern to select matching customer records.

```sql
SELECT CustomerID, CompanyName, PostalCode
FROM customers
WHERE PostalCode LIKE '10%';
```

### 3. Number of customers by country

Group customers by country and count the records in each group.

```sql
SELECT Country, COUNT(CustomerID) AS CustomerCount
FROM customers
GROUP BY Country;
```

### 4. Number of customers and employees by city

Build a combined list of cities, count each group separately, and display zero when a group has no matching records.

```sql
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
) AS employees ON cities.City = employees.City
ORDER BY cities.City;
```

### 5. Total freight by shipping company

Include every shipper and round its total freight to the nearest whole number. Shippers without a freight total are shown with zero.

```sql
SELECT
    shippers.CompanyName,
    COALESCE(ROUND(SUM(orders.Freight), 0), 0) AS TotalFreight
FROM shippers
LEFT JOIN orders ON shippers.ShipperID = orders.ShipVia
GROUP BY shippers.ShipperID, shippers.CompanyName;
```

### 6. Products and categories using a subquery

For each product, look up its category name using the matching category ID.

```sql
SELECT
    ProductName,
    (
        SELECT CategoryName
        FROM categories
        WHERE categories.CategoryID = products.CategoryID
    ) AS CategoryName
FROM products;
```

### 7. Countries with both customers and suppliers

Find the intersection of the two country lists. Duplicate country names appear only once.

```sql
SELECT Country FROM customers
INTERSECT
SELECT Country FROM suppliers;
```

## Practical assignment 2.1 — database administration

These exercises use MySQL and the Northwind database. The examples below follow the work in `variant-4.sql`. They change the database: category ID `9`, shipper IDs `10` and `11`, and the procedure, trigger, table, and view names must be available when the corresponding creation statements run. Repeating an `INSERT` or `CREATE` against an existing object can fail. Run each statement deliberately and inspect the result before continuing.

### 1. Transaction and isolation

Create a category in a transaction using `REPEATABLE READ`, check the inserted row, and commit the change:

```sql
USE northwind;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

INSERT INTO categories (CategoryID, CategoryName)
VALUES (9, 'Snacks');

SELECT CategoryID, CategoryName
FROM categories
WHERE CategoryID = 9;

COMMIT;
```

The `SELECT` can see the transaction's own insert before `COMMIT`. `COMMIT` persists it; `ROLLBACK` can instead discard an uncommitted transaction. The ID must be unique. This example uses one connection and does not by itself demonstrate concurrent isolation behavior.

### 2. Stored procedure

`AddShippers` accepts an ID, company name, and phone number and adds a row to `shippers`. `ShipperID` in this dataset is a primary key and must be provided explicitly.

```sql
CREATE PROCEDURE AddShippers(
    IN p_id INT,
    IN p_company_name VARCHAR(40),
    IN p_phone VARCHAR(24)
)
INSERT INTO shippers (ShipperID, CompanyName, Phone)
VALUES (p_id, p_company_name, p_phone);

CALL AddShippers(10, 'New Shipper', '098999999');
SELECT ShipperID, CompanyName, Phone
FROM shippers
WHERE ShipperID = 10;
```

Creating the procedure stores the instruction; `CALL` executes it. This single-statement procedure does not require a `BEGIN ... END` block.

### 3. Trigger and audit table

Create the log table before the trigger. After each insert into `shippers`, the trigger copies the new row's details to the log. Existing rows are not logged retroactively.

```sql
CREATE TABLE ShippersLog (
    ShipperID INT,
    CompanyName VARCHAR(40),
    Phone VARCHAR(24)
);

CREATE TRIGGER trg_shippers_log
AFTER INSERT ON shippers
FOR EACH ROW
INSERT INTO ShippersLog (ShipperID, CompanyName, Phone)
VALUES (NEW.ShipperID, NEW.CompanyName, NEW.Phone);

CALL AddShippers(11, 'New Shipper2', '098999499');
SELECT * FROM shippers WHERE ShipperID = 11;
SELECT * FROM ShippersLog WHERE ShipperID = 11;
```

`NEW` refers to the row being inserted. Both queries should show the new shipper after a successful call. This simple log stores shipper data but has no separate event ID or timestamp.

### 4. View

The following view reuses the customer and employee counts by city from query 4 above. It groups each source separately before joining the results, so customers and employees do not multiply each other's counts.

```sql
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
```

The view stores the query definition, and the final `SELECT` specifies the ordering. The original wording and numbering of laboratory 2 exercise 4 should be checked before submission.

### 5. User privileges

The assignment asks for a user, five database-level privileges, revocation of `CREATE`, and removal of the user. Replace the placeholder with a local test password. Execute these steps using an account with sufficient administrative privileges.

```sql
CREATE USER 'BondarenkoOlehTCR31'@'localhost'
IDENTIFIED BY '<local-test-password>';

GRANT CREATE, INSERT, UPDATE, DELETE, SELECT
ON northwind.*
TO 'BondarenkoOlehTCR31'@'localhost';

SHOW GRANTS FOR 'BondarenkoOlehTCR31'@'localhost';

REVOKE CREATE ON northwind.*
FROM 'BondarenkoOlehTCR31'@'localhost';

SHOW GRANTS FOR 'BondarenkoOlehTCR31'@'localhost';

DROP USER 'BondarenkoOlehTCR31'@'localhost';
```

Check the grants before and after `REVOKE`: the second result should omit `CREATE` while retaining the other privileges. After `DROP USER`, the account no longer exists; `SHOW GRANTS` for it will fail. The successful `REVOKE` and `DROP USER` were observed in the execution log; a separate screenshot of grants after revocation was not captured.

**Submission:** the assignment requests SQL code and screenshots of execution for each task. The previous seven query exercises remain documented in this README.

