USE northwind;

-- =====================================================
-- SECCIÓN 1 – ANÁLISIS DE VENTAS
-- =====================================================

-- 1. Top 10 productos que más ingresos han generado
SELECT
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity * od.UnitPrice) AS TotalIngresos
FROM OrderDetails od
JOIN Products p 
    ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalIngresos DESC
LIMIT 10;

-- 2. Categorías de productos más rentables
SELECT
    c.CategoryID,
    c.CategoryName,
    SUM(od.Quantity * od.UnitPrice) AS TotalIngresos
FROM OrderDetails od
JOIN Products p    
    ON p.ProductID = od.ProductID
JOIN Categories c  
    ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalIngresos DESC;

-- 3. Cliente con mayor valor total de compras
SELECT
    cu.CustomerID,
    cu.CompanyName,
    SUM(od.Quantity * od.UnitPrice) AS ValorTotalCompras
FROM Customers cu
JOIN Orders o       
    ON o.CustomerID = cu.CustomerID
JOIN OrderDetails od 
    ON od.OrderID = o.OrderID
GROUP BY cu.CustomerID, cu.CompanyName
ORDER BY ValorTotalCompras DESC
LIMIT 1;

-- 4. País que generó más ingresos en los últimos 12 meses
SELECT
    cu.Country,
    SUM(od.Quantity * od.UnitPrice) AS Ingresos_12_Meses
FROM Orders o
JOIN Customers cu     
    ON cu.CustomerID = o.CustomerID
JOIN OrderDetails od  
    ON od.OrderID = o.OrderID
WHERE o.OrderDate >= DATE_SUB(
    (SELECT MAX(OrderDate) FROM Orders),
    INTERVAL 12 MONTH
)
GROUP BY cu.Country
ORDER BY Ingresos_12_Meses DESC
LIMIT 1;

-- 5. Empleado que gestionó mayor cantidad de pedidos
SELECT 
    e.FirstName,
    e.LastName,
    COUNT(o.OrderID) AS TotalPedidos
FROM Employees e
JOIN Orders o 
    ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY TotalPedidos DESC
LIMIT 1;

-- =====================================================
-- SECCIÓN 2 – COMPORTAMIENTO DE CLIENTES
-- =====================================================

-- 1. Porcentaje de clientes que no han comprado nada
SELECT 
    ROUND(
        COUNT(c.CustomerID) * 100.0 / (SELECT COUNT(*) FROM Customers),
        2
    ) AS PorcentajeSinCompras
FROM Customers c
LEFT JOIN Orders o 
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- 2. Top 5 países con más clientes activos
SELECT 
    c.Country, 
    COUNT(DISTINCT c.CustomerID) AS ClientesActivos
FROM Customers c
JOIN Orders o 
    ON c.CustomerID = o.CustomerID
GROUP BY c.Country
ORDER BY ClientesActivos DESC
LIMIT 5;

-- 3. Clientes que han comprado más de 10 productos distintos
SELECT 
    c.CompanyName, 
    COUNT(DISTINCT od.ProductID) AS ProductosDistintos
FROM Customers c
JOIN Orders o 
    ON c.CustomerID = o.CustomerID
JOIN OrderDetails od 
    ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CompanyName
HAVING COUNT(DISTINCT od.ProductID) > 10
ORDER BY ProductosDistintos DESC;

-- 4. Clientes que compran solo una categoría de producto
SELECT 
    c.CompanyName
FROM Customers c
JOIN Orders o 
    ON c.CustomerID = o.CustomerID
JOIN OrderDetails od 
    ON o.OrderID = od.OrderID
JOIN Products p 
    ON od.ProductID = p.ProductID
GROUP BY c.CompanyName
HAVING COUNT(DISTINCT p.CategoryID) = 1;

-- 5. Ticket promedio por pedido y variación entre países
SELECT 
    Country,
    ROUND(AVG(Pedido_Total), 2) AS Ticket_Promedio
FROM (
    SELECT 
        o.OrderID,
        c.Country,
        SUM(od.UnitPrice * od.Quantity) AS Pedido_Total
    FROM Orders o
    JOIN Customers c 
        ON o.CustomerID = c.CustomerID
    JOIN OrderDetails od 
        ON o.OrderID = od.OrderID
    GROUP BY o.OrderID, c.Country
) sub
GROUP BY Country
ORDER BY Ticket_Promedio DESC;

-- =====================================================
-- SECCIÓN 3 – RENDIMIENTO Y OPTIMIZACIÓN
-- =====================================================

-- 1. Ranking de clientes por gasto total
SELECT 
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity) AS Total_Gastado,
    RANK() OVER (
        ORDER BY SUM(od.UnitPrice * od.Quantity) DESC
    ) AS Ranking
FROM Customers c
JOIN Orders o 
    ON c.CustomerID = o.CustomerID
JOIN OrderDetails od 
    ON o.OrderID = od.OrderID
GROUP BY c.CompanyName;

-- 2. Total de productos vendidos por mes
SELECT 
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS Mes,
    SUM(od.Quantity) AS Productos_Vendidos
FROM Orders o
JOIN OrderDetails od 
    ON o.OrderID = od.OrderID
GROUP BY Mes
ORDER BY Mes;

-- 3. Mejor mes en ventas del último año
SELECT 
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS Mes,
    ROUND(SUM(od.Quantity * od.UnitPrice), 2) AS TotalVentas
FROM Orders o
JOIN OrderDetails od 
    ON o.OrderID = od.OrderID
WHERE o.OrderDate >= (
    SELECT DATE_SUB(MAX(OrderDate), INTERVAL 1 YEAR)
    FROM Orders
)
GROUP BY Mes
ORDER BY TotalVentas DESC
LIMIT 1;

-- 4. Evolución del gasto acumulado por cliente
SELECT 
    c.CompanyName,
    o.OrderDate,
    SUM(od.Quantity * od.UnitPrice) OVER (
        PARTITION BY c.CustomerID
        ORDER BY o.OrderDate
    ) AS GastoAcumulado
FROM Customers c
JOIN Orders o 
    ON c.CustomerID = o.CustomerID
JOIN OrderDetails od 
    ON o.OrderID = od.OrderID
ORDER BY c.CompanyName, o.OrderDate;

-- 5. Productos que se repiten como más vendidos por trimestre
WITH VentasTrimestrales AS (
    SELECT 
        YEAR(o.OrderDate) AS Anio,
        QUARTER(o.OrderDate) AS Trimestre,
        p.ProductName,
        SUM(od.Quantity) AS TotalVendido,
        RANK() OVER (
            PARTITION BY YEAR(o.OrderDate), QUARTER(o.OrderDate)
            ORDER BY SUM(od.Quantity) DESC
        ) AS Ranking
    FROM Orders o
    JOIN OrderDetails od 
        ON o.OrderID = od.OrderID
    JOIN Products p 
        ON od.ProductID = p.ProductID
    GROUP BY Anio, Trimestre, p.ProductName
)
SELECT 
    ProductName,
    COUNT(*) AS VecesLider,
    GROUP_CONCAT(CONCAT('T', Trimestre, '-', Anio)) AS Periodos
FROM VentasTrimestrales
WHERE Ranking = 1
GROUP BY ProductName
HAVING VecesLider > 1
ORDER BY VecesLider DESC;
