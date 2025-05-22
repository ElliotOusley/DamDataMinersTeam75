
-- PL.SQL
-- This file contains PL/SQL stored procedures to RESET each table in the Sea Otter Grocery database.
-- Authors: Hau'oli O'Brien and Elliot Ousley
-- AI Usage: I used AI to help generate the initial structure and syntax for the PL/SQL reset procedures,
then I customized to fit our project’s schema and requirements.

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
        customer_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL
    );
    INSERT INTO Customers (name, email)
    VALUES 
        ('Sidney SeaLion', 'sidney@example.com'),
        ('Syrus SeaOtter', 'syrus@example.com');
END //

CREATE PROCEDURE ResetSuppliers()
BEGIN
    DROP TABLE IF EXISTS Suppliers;
    CREATE TABLE Suppliers (
        supplier_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100),
        location VARCHAR(100)
    );
    INSERT INTO Suppliers (name, email, location)
    VALUES 
        ('Organic Farms Co.', 'contact@organicfarms.com', 'Oregon'),
        ('Coastal Harvest', 'info@coastalharvest.com', 'Washington');
END //

CREATE PROCEDURE ResetProducts()
BEGIN
    DROP TABLE IF EXISTS Products;
    CREATE TABLE Products (
        product_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        quantity INT NOT NULL,
        supplier_id INT,
        FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
    );
    INSERT INTO Products (name, price, quantity, supplier_id)
    VALUES 
        ('Seaweed Snacks', 2.50, 100, 1),
        ('Fresh Salmon', 12.00, 50, 2);
END //

CREATE PROCEDURE ResetOrders()
BEGIN
    DROP TABLE IF EXISTS Orders;
    CREATE TABLE Orders (
        order_id INT AUTO_INCREMENT PRIMARY KEY,
        customer_id INT,
        order_date DATE,
        status VARCHAR(50),
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
    );
    INSERT INTO Orders (customer_id, order_date, status)
    VALUES 
        (1, '2025-05-01', 'Delivered'),
        (2, '2025-05-02', 'Pending');
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
    INSERT INTO OrderItems (order_id, product_id, quantity, price)
    VALUES 
        (1, 1, 2, 5.00),
        (2, 2, 1, 12.00);
END //

CREATE PROCEDURE ResetReviews()
BEGIN
    DROP TABLE IF EXISTS Reviews;
    CREATE TABLE Reviews (
        review_id INT AUTO_INCREMENT PRIMARY KEY,
        customer_id INT,
        product_id INT,
        rating INT CHECK (rating BETWEEN 1 AND 5),
        comment TEXT,
        review_date DATE,
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
    );
    INSERT INTO Reviews (customer_id, product_id, rating, comment, review_date)
    VALUES 
        (1, 1, 5, 'Great seaweed snacks!', '2025-05-03'),
        (2, 2, 4, 'Salmon was fresh but pricey.', '2025-05-04');
END //

DELIMITER ;
