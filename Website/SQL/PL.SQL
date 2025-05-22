
-- PL.SQL
-- This file contains PL/SQL stored procedures to RESET each table in the Sea Otter Grocery database.
-- Authors: Hau'oli O'Brien and Elliot Ousley
-- AI Usage: I used AI to help generate the initial structure and syntax for the PL/SQL reset procedures,
-- then I customized to fit our project’s schema and requirements.

DROP PROCEDURE IF EXISTS ResetCustomers;
DROP PROCEDURE IF EXISTS ResetSuppliers;
DROP PROCEDURE IF EXISTS ResetProducts;
DROP PROCEDURE IF EXISTS ResetOrders;
DROP PROCEDURE IF EXISTS ResetOrderItems;
DROP PROCEDURE IF EXISTS ResetReviews;

DELIMITER //

CREATE PROCEDURE ResetCustomers()
BEGIN
    DROP TABLE IF EXISTS Customers;
    CREATE TABLE Customers (
        CustomerID INT NOT NULL AUTO_INCREMENT,
        Name VARCHAR(100) NOT NULL,
        Species VARCHAR(50) NOT NULL,
        Address VARCHAR(100),
        ContactEmail VARCHAR(100) NOT NULL,
        PRIMARY KEY (CustomerID)
    );

    INSERT INTO Customers (Name, Species, Address, ContactEmail)
    VALUES('Sam Shell', 'Sea Otter', '1200 Kelp Forest Way', 'shells@seamail.com'),
    ('Luna Splash', 'Harbor Seal', '234 Moonlit Tide Ln', 'lunas@seamail.com'),
    ('Rocky Paws', 'Sea Lion', '567 Pebble Beach Blvd', 'rockyp@seamail.com');

END //

CREATE PROCEDURE ResetSuppliers()
BEGIN
    DROP TABLE IF EXISTS Suppliers;
    CREATE TABLE Suppliers (
        SupplierID INT AUTO_INCREMENT,
        Name VARCHAR(100) NOT NULL,
        ContactEmail VARCHAR(100),
        Location VARCHAR(100),
        PRIMARY KEY (SupplierID)
    );
    INSERT INTO Suppliers (Name, ContactEmail, Location)
    Values('Kelp Fisheries', 'contact@kelpfisheries.com', 'Kelp City'),
    ('Crabby Co.', 'contact@crabbyco.com', 'Crab Island'),
    ('Deep Sea Harvesters', 'contact@deepsea.com', 'Trench Town'),
    ('Seagrass Suppliers', 'contact@seagrasssuppliers.com', 'Seagrass Flats');

END //

CREATE PROCEDURE ResetProducts()
BEGIN
    DROP TABLE IF EXISTS Products;
    CREATE TABLE Products (
        ProductID INT NOT NULL AUTO_INCREMENT,
        Name VARCHAR(100) NOT NULL,
        Category VARCHAR(50) NOT NULL,
        PricePerUnit DECIMAL NOT NULL,
        Quantity INT NOT NULL,
        IsSeasonal TINYINT NOT NULL DEFAULT 0,
        SupplierID INT NOT NULL,
        PRIMARY KEY (ProductID),
        FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
    );
    INSERT INTO Products (Name, Category, PricePerUnit, Quantity, SupplierID)
    VALUES('Cod Roe', 'Roe', 1.50, 1500, (SELECT SupplierID FROM Suppliers WHERE Name = 'Kelp Fisheries')),
    ('Rockfish Fillet', 'Fish', 4.25, 800, (SELECT SupplierID FROM Suppliers WHERE Name = 'Deep Sea Harvesters')),
    ('Crab Claws', 'Shellfish', 6.75, 600, (SELECT SupplierID FROM Suppliers WHERE Name = 'Crabby Co.'));
END //

CREATE PROCEDURE ResetOrders()
BEGIN
    DROP TABLE IF EXISTS Orders;
    CREATE TABLE Orders (
        OrderID INT NOT NULL AUTO_INCREMENT,
        OrderDate DATE NOT NULL,
        OrderStatus ENUM('pending', 'shipped', 'delivered', 'cancelled') NOT NULL,
        CustomerID INT NOT NULL,
        PRIMARY KEY (OrderID),
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    );
    INSERT INTO Orders (OrderDate, OrderStatus, CustomerID)
    VALUES ('2025-04-25', 'pending', (SELECT CustomerID FROM Customers WHERE Name = 'Sam Shell')),
    ('2025-03-15', 'shipped', (SELECT CustomerID FROM Customers WHERE Name = 'Luna Splash')),
    ('2025-05-01', 'delivered', (SELECT CustomerID FROM Customers WHERE Name = 'Rocky Paws'));

END //

CREATE PROCEDURE ResetOrderItems()
BEGIN
    DROP TABLE IF EXISTS OrderItems;
    CREATE TABLE OrderItems (
        order_item_id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT,
        product_id INT,
        quantity INT,
        price DECIMAL(10,2),
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
    );
    INSERT INTO OrderItems (ProductID, OrderID, Quantity, Price)
    VALUES ((SELECT ProductID FROM Products WHERE Name = 'Cod Roe'), 
    (SELECT OrderID FROM Orders WHERE CustomerID = (SELECT CustomerID FROM Customers WHERE Name = 'Sam Shell')), 3, 4.50),
    ((SELECT ProductID FROM Products WHERE Name = 'Rockfish Fillet'),
    (SELECT OrderID FROM Orders WHERE CustomerID = (SELECT CustomerID FROM Customers WHERE Name = 'Luna Splash')), 2, 8.50),
    ((SELECT ProductID FROM Products WHERE Name = 'Crab Claws'),
    (SELECT OrderID FROM Orders WHERE CustomerID = (SELECT CustomerID FROM Customers WHERE Name = 'Rocky Paws')), 1, 6.75);
END //

CREATE PROCEDURE ResetReviews()
BEGIN
    DROP TABLE IF EXISTS Reviews;
    CREATE TABLE Reviews (
        OrderItemsID INT NOT NULL AUTO_INCREMENT,
        ProductID INT NOT NULL,
        OrderID INT NOT NULL,
        Quantity INT,
        Price DECIMAL(5,2) NOT NULL,
        PRIMARY KEY (OrderItemsID),
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
    );
    INSERT INTO Reviews (CustomerID, ReviewDate, Rating, Comment, ProductID)
    VALUES ((SELECT CustomerID FROM Customers WHERE Name = 'Sam Shell'), '2025-04-27', 5, 'Best roe I''ve ever had.', (SELECT ProductID FROM Products WHERE Name = 'Cod Roe')),
    ((SELECT CustomerID FROM Customers WHERE Name = 'Luna Splash'), '2025-03-20', 4, 'The rockfish fillets were great!!', (SELECT ProductID FROM Products WHERE Name = 'Rockfish Fillet')),
    ((SELECT CustomerID FROM Customers WHERE Name = 'Rocky Paws'), '2025-05-02', 3, 'Not too bad. A little salty', (SELECT ProductID FROM Products WHERE Name = 'Crab Claws'));

END //

DELIMITER ;

-- TODO: Create a function called resetall