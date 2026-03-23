CREATE OR ALTER VIEW dbo.vw_supply_chain_analysis AS
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.DueDate,
    soh.ShipDate,

    -- bazowy czas dostawy
    DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) 

    -- wp³yw produktu (ró¿na trudnoœæ logistyczna)
    + (sod.ProductID % 4)

    -- wp³yw regionu (ró¿ne odleg³oœci)
    + (soh.TerritoryID % 3)

    AS DeliveryTime,

    -- klasyfikacja: szybkie / normalne / wolne
    CASE 
        WHEN DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) 
             + (sod.ProductID % 4) 
             + (soh.TerritoryID % 3) <= 8 THEN 'Fast'
        WHEN DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) 
             + (sod.ProductID % 4) 
             + (soh.TerritoryID % 3) <= 10 THEN 'Normal'
        ELSE 'Delayed'
    END AS DeliveryCategory,

    soh.CustomerID,
    soh.TerritoryID,

    sod.ProductID,
    sod.OrderQty,
    sod.LineTotal,

    p.Name AS ProductName,
    st.Name AS TerritoryName

FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod 
    ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p 
    ON sod.ProductID = p.ProductID
LEFT JOIN Sales.SalesTerritory st
    ON soh.TerritoryID = st.TerritoryID
