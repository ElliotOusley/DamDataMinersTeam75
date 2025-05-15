-- Author: Elliot Ousley
-- Author: Hau'oli O'Brien
--Citation for: Data Definition
--Date: 5/8/25
--Adapted from Exploration - bsg_sample_data_manipulation_queries.sql
--Source URL: https://canvas.oregonstate.edu/courses/1999601/assignments/10006387



-- Customers --
SELECT Name, Species, Address, ContactEmail FROM Customers; 

INSERT INTO Customers (Name, Species, Address, ContactEmail)
VALUES (:nameInput, :speciesInput, :addressInput, :contactEmailInput);

UPDATE Customers
SET Name = :name,
    Species = :speciesInput,
    Address = :addressInput,
    ContactEmail = :contactEmailInput
WHERE CustomerID = :customerIDInput;

DELETE FROM Customers
WHERE CustomerID = :customerIDInput;

---------------

-- Suppliers --
SELECT Name, ContactEmail, Location FROM Suppliers;

INSERT INTO Suppliers (Name, ContactEmail, Location)
VALUES (:nameInput, :contactEmailInput, :locationInput);

UPDATE Suppliers
SET Name = :nameInput,
    ContactEmail = :contactEmailInput,
    Location = :locationInput
WHERE SupplierID = :supplierIDInput;

DELETE FROM Suppliers
WHERE SupplierID = :supplierIDInput;

---------------

-- Products --
SELECT Name, Category, PricePerUnit, Quantity, IsSeasonal, SupplierID FROM Products;

INSERT INTO Products (Name, Category, PricePerUnit, Quantity, IsSeasonal, SupplierID)
VALUES (:nameInput, :categoryInput, :priceInput, :quantityInput, :isSeasonalInput, :supplierIDInput);

UPDATE Products
SET Name = :nameInput,
    Category = :categoryInput,
    PricePerUnit = :priceInput,
    Quantity = :quantityInput,
    IsSeasonal = :isSeasonalInput,
    SupplierID = :supplierIDInput
WHERE ProductID = :productIDInput;

DELETE FROM Products
WHERE ProductID = :productIDInput;

---------------

-- Orders --
SELECT OrderDate, OrderStatus, CustomerID FROM Orders;

INSERT INTO Orders (OrderDate, OrderStatus, CustomerID)
VALUES (:orderDateInput, :statusInput, :customerIDInput);

UPDATE Orders
SET OrderDate = :orderDateInput,
    OrderStatus = :statusInput,
    CustomerID = :customerIDInput
WHERE OrderID = :orderIDInput;

DELETE FROM Orders
WHERE OrderID = :orderIDInput;

---------------

-- OrderItems --
SELECT ProductID, OrderID, Quantity, Price FROM OrderItems;

INSERT INTO OrderItems (ProductID, OrderID, Quantity, Price)
VALUES (:productIDInput, :orderIDInput, :quantityInput, :priceInput);

UPDATE OrderItems
SET ProductID = :productIDInput,
    OrderID = :orderIDInput,
    Quantity = :quantityInput,
    Price = :priceInput
WHERE OrderItemsID = :orderItemsIDInput;

DELETE FROM OrderItems
WHERE OrderItemsID = :orderItemsIDInput;

---------------

-- Reviews --
SELECT CustomerID, ReviewDate, Rating, Comment, ProductID FROM Reviews;

INSERT INTO Reviews (CustomerID, ReviewDate, Rating, Comment, ProductID)
VALUES (:customerIDInput, :reviewDateInput, :ratingInput, :commentInput, :productIDInput);

UPDATE Reviews
SET CustomerID = :customerIDInput,
    ReviewDate = :reviewDateInput,
    Rating = :ratingInput,
    Comment = :commentInput,
    ProductID = :productIDInput
WHERE ReviewID = :reviewIDInput;

DELETE FROM Reviews
WHERE ReviewID = :reviewIDInput;

---------------