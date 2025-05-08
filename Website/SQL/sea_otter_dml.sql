-- INSERT CUSTOMER
INSERT INTO Customers (Name, Species, Address, ContactEmail)
VALUES (@name, @species, @address, @contactEmail);

-- SELECT ALL PRODUCTS
SELECT * FROM Products;

-- INSERT PRODUCT
INSERT INTO Products (Name, Item, PricePerUnit, Quantity, SupplierID)
VALUES (@name, @item, @price, @quantity, @supplierID);

-- UPDATE ORDER STATUS
UPDATE Orders SET OrderStatus = @status WHERE OrderID = @orderID;

-- DELETE REVIEW
DELETE FROM Reviews WHERE ReviewID = @reviewID;

