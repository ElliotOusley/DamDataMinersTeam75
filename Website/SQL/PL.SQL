
-- PL.SQL
-- This file contains PL/SQL stored procedures to RESET each table in the Sea Otter Grocery database.
-- Authors: Hau'oli O'Brien and Elliot Ousley

DROP PROCEDURE IF EXISTS ResetCustomers;
DROP PROCEDURE IF EXISTS ResetSuppliers;
DROP PROCEDURE IF EXISTS ResetProducts;
DROP PROCEDURE IF EXISTS ResetOrders;
DROP PROCEDURE IF EXISTS ResetOrderItems;
DROP PROCEDURE IF EXISTS ResetReviews;
DROP PROCEDURE IF EXISTS ResetAll;

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
            ON DELETE CASCADE
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
            ON DELETE CASCADE
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
    INSERT INTO Reviews (CustomerID, ReviewDate, Rating, Comment, ProductID)
    VALUES ((SELECT CustomerID FROM Customers WHERE Name = 'Sam Shell'), '2025-04-27', 5, 'Best roe I''ve ever had.', (SELECT ProductID FROM Products WHERE Name = 'Cod Roe')),
    ((SELECT CustomerID FROM Customers WHERE Name = 'Luna Splash'), '2025-03-20', 4, 'The rockfish fillets were great!!', (SELECT ProductID FROM Products WHERE Name = 'Rockfish Fillet')),
    ((SELECT CustomerID FROM Customers WHERE Name = 'Rocky Paws'), '2025-05-02', 3, 'Not too bad. A little salty', (SELECT ProductID FROM Products WHERE Name = 'Crab Claws'));

END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE ResetAll()
BEGIN
    SET foreign_key_checks = 0; 
    CALL ResetCustomers();
    CALL ResetSuppliers();
    CALL ResetProducts();
    CALL ResetOrders();
    CALL ResetOrderItems();
    CALL ResetReviews();
END //

DELIMITER ;


-- #############################
-- CREATE customer
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateCustomer;

DELIMITER //
CREATE PROCEDURE sp_CreateCustomer(
    IN p_name VARCHAR(100), 
    IN p_species VARCHAR(50), 
    IN p_address VARCHAR(100), 
    IN p_contactemail VARCHAR(100),
    OUT p_id INT)
BEGIN
    INSERT INTO Customers (Name, Species, Address, ContactEmail) 
    VALUES (p_name, p_species, p_address, p_contactemail);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;

-- #############################
-- CREATE supplier
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateSupplier;

DELIMITER //
CREATE PROCEDURE sp_CreateSupplier(
    IN p_name VARCHAR(100), 
    IN p_email VARCHAR(100), 
    IN p_location VARCHAR(100),
    OUT p_id INT)
BEGIN
    INSERT INTO Customers (Name, ContactEmail, Location) 
    VALUES (p_name, p_email, p_location);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;

-- #############################
-- UPDATE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateCustomer;

DELIMITER //
CREATE PROCEDURE sp_UpdateCustomer(
    IN p_id INT, 
    IN p_address VARCHAR(100), 
    IN p_contactemail VARCHAR(100))

BEGIN
    UPDATE Customers SET Address = p_address, ContactEmail = p_contactemail WHERE CustomerID = p_id; 
END //
DELIMITER ;

-- #############################
-- UPDATE Supplier
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateSupplier;

DELIMITER //
CREATE PROCEDURE sp_UpdateSupplier(
    IN p_id INT, 
    IN p_contactemail VARCHAR(100), 
    IN p_location VARCHAR(100))

BEGIN
    UPDATE Suppliers SET ContactEmail = p_contactemail, Location = p_location WHERE SupplierID = p_id; 
END //
DELIMITER ;


-- #############################
-- DELETE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteCustomer;

DELIMITER //
CREATE PROCEDURE sp_DeleteCustomer(IN p_id INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both bsg_people table and 
        --      intersection table to prevent a data anamoly
        -- This can also be accomplished by using an 'ON DELETE CASCADE' constraint
        --      inside the bsg_cert_people table.
        DELETE FROM Orders WHERE CustomerID = p_id;
        DELETE FROM Reviews WHERE CustomerID = p_id;
        DELETE FROM Customers WHERE CustomerID = p_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in bsg_people for id: ', p_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;


-- #############################
-- DELETE Supplier
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteSupplier;

DELIMITER //
CREATE PROCEDURE sp_DeleteSupplier(IN p_id INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Deleting corresponding rows from both bsg_people table and 
        --      intersection table to prevent a data anamoly
        -- This can also be accomplished by using an 'ON DELETE CASCADE' constraint
        --      inside the bsg_cert_people table.
        DELETE FROM Products WHERE SupplierID = p_id;
        DELETE FROM Suppliers WHERE SupplierID = p_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in bsg_people for id: ', p_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;