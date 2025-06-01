
-- Author: Elliot Ousley
-- Author: Hau'oli O'Brien

SET FOREIGN_KEY_CHECKS=0;

-- Creating Tables --
CREATE OR REPLACE TABLE Customers (
  CustomerID INT NOT NULL AUTO_INCREMENT,
  Name VARCHAR(100) NOT NULL,
  Species VARCHAR(50) NOT NULL,
  Address VARCHAR(100),
  ContactEmail VARCHAR(100) NOT NULL,
  PRIMARY KEY (CustomerID)
);



CREATE OR REPLACE TABLE Suppliers (
  SupplierID INT NOT NULL AUTO_INCREMENT,
  Name VARCHAR(100),
  ContactEmail VARCHAR(100),
  Location VARCHAR(100),
  PRIMARY KEY (SupplierID)
);



CREATE OR REPLACE TABLE Products (
  ProductID INT NOT NULL AUTO_INCREMENT,
  Name VARCHAR(100) NOT NULL,
  Category VARCHAR(50) NOT NULL,
  PricePerUnit DECIMAL NOT NULL,
  Quantity INT NOT NULL,
  IsSeasonal TINYINT NOT NULL DEFAULT 0,
  SupplierID INT NOT NULL,
  PRIMARY KEY (ProductID),
  FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
    ON DELETE CASCADE
);



CREATE OR REPLACE TABLE Orders (
  OrderID INT NOT NULL AUTO_INCREMENT,
  OrderDate DATE NOT NULL,
  OrderStatus ENUM('pending', 'shipped', 'delivered', 'cancelled') NOT NULL,
  CustomerID INT NOT NULL,
  PRIMARY KEY (OrderID),
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON DELETE CASCADE
);



CREATE OR REPLACE TABLE OrderItems (
  OrderItemsID INT NOT NULL AUTO_INCREMENT,
  ProductID INT NOT NULL,
  OrderID INT NOT NULL,
  Quantity INT,
  Price DECIMAL(5,2) NOT NULL,
  PRIMARY KEY (OrderItemsID),
  FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    ON DELETE CASCADE,
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
    ON DELETE CASCADE
);



CREATE OR REPLACE TABLE Reviews (
  ReviewID INT NOT NULL AUTO_INCREMENT,
  CustomerID INT NOT NULL,
  ReviewDate DATE NOT NULL,
  Rating INT NOT NULL,
  Comment LONGTEXT,
  ProductID INT NOT NULL,
  PRIMARY KEY (ReviewID),
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON DELETE CASCADE,
  FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    ON DELETE CASCADE
);



-- Insert Statements --
INSERT INTO Customers (Name, Species, Address, ContactEmail)
VALUES('Sam Shell', 'Sea Otter', '1200 Kelp Forest Way', 'shells@seamail.com'),
('Luna Splash', 'Harbor Seal', '234 Moonlit Tide Ln', 'lunas@seamail.com'),
('Rocky Paws', 'Sea Lion', '567 Pebble Beach Blvd', 'rockyp@seamail.com');



INSERT INTO Suppliers (Name, ContactEmail, Location)
Values('Kelp Fisheries', 'contact@kelpfisheries.com', 'Kelp City'),
('Crabby Co.', 'contact@crabbyco.com', 'Crab Island'),
('Deep Sea Harvesters', 'contact@deepsea.com', 'Trench Town'),
('Seagrass Suppliers', 'contact@seagrasssuppliers.com', 'Seagrass Flats');



INSERT INTO Products (Name, Category, PricePerUnit, Quantity, SupplierID)
VALUES('Cod Roe', 'Roe', 1.50, 1500, (SELECT SupplierID FROM Suppliers WHERE Name = 'Kelp Fisheries')),
('Rockfish Fillet', 'Fish', 4.25, 800, (SELECT SupplierID FROM Suppliers WHERE Name = 'Deep Sea Harvesters')),
('Crab Claws', 'Shellfish', 6.75, 600, (SELECT SupplierID FROM Suppliers WHERE Name = 'Crabby Co.'));



INSERT INTO Orders (OrderDate, OrderStatus, CustomerID)
VALUES ('2025-04-25', 'pending', (SELECT CustomerID FROM Customers WHERE Name = 'Sam Shell')),
('2025-03-15', 'shipped', (SELECT CustomerID FROM Customers WHERE Name = 'Luna Splash')),
('2025-05-01', 'delivered', (SELECT CustomerID FROM Customers WHERE Name = 'Rocky Paws'));



INSERT INTO OrderItems (ProductID, OrderID, Quantity, Price)
VALUES ((SELECT ProductID FROM Products WHERE Name = 'Cod Roe'), 
(SELECT OrderID FROM Orders WHERE CustomerID = (SELECT CustomerID FROM Customers WHERE Name = 'Sam Shell')), 3, 4.50),
((SELECT ProductID FROM Products WHERE Name = 'Rockfish Fillet'),
(SELECT OrderID FROM Orders WHERE CustomerID = (SELECT CustomerID FROM Customers WHERE Name = 'Luna Splash')), 2, 8.50),
((SELECT ProductID FROM Products WHERE Name = 'Crab Claws'),
(SELECT OrderID FROM Orders WHERE CustomerID = (SELECT CustomerID FROM Customers WHERE Name = 'Rocky Paws')), 1, 6.75);



INSERT INTO Reviews (CustomerID, ReviewDate, Rating, Comment, ProductID)
VALUES ((SELECT CustomerID FROM Customers WHERE Name = 'Sam Shell'), '2025-04-27', 5, 'Best roe I''ve ever had.', (SELECT ProductID FROM Products WHERE Name = 'Cod Roe')),
((SELECT CustomerID FROM Customers WHERE Name = 'Luna Splash'), '2025-03-20', 4, 'The rockfish fillets were great!!', (SELECT ProductID FROM Products WHERE Name = 'Rockfish Fillet')),
((SELECT CustomerID FROM Customers WHERE Name = 'Rocky Paws'), '2025-05-02', 3, 'Not too bad. A little salty', (SELECT ProductID FROM Products WHERE Name = 'Crab Claws'));


SET FOREIGN_KEY_CHECKS=1;