# Northwind SQL Practice

**Variant 4 · MySQL · Relational database queries**

This project explores the Northwind sample database through seven practical SQL exercises. It starts with filtering individual records and builds up to aggregations, joins, a correlated subquery, and a set operation.

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
- `variant-4.sql` — the current exercise query.
- `Northwind_PR1_2_Variant4.sln` — the JetBrains Rider solution.

## Getting started

1. Connect Rider to a MySQL server that supports `INTERSECT` (MySQL 8.0.31 or newer).
2. Import the dump if you do not already have the Northwind database. The dump contains `DROP TABLE IF EXISTS` statements, so importing it can replace existing tables in `northwind`.
3. Open `variant-4.sql`, select the `northwind` database connection, and execute the query.

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

The current `variant-4.sql` contains the query for exercise 7; the earlier queries are documented above.
