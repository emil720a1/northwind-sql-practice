USE northwind;

SELECT Country FROM Customers
INTERSECT
SELECT Country FROM Suppliers;