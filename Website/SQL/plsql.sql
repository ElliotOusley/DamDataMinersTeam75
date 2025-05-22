-- #############################
-- CREATE bsg_people
-- #############################
DROP PROCEDURE IF EXISTS sp_CreatePerson;

DELIMITER //
CREATE PROCEDURE sp_CreatePerson(
    IN p_fname VARCHAR(255), 
    IN p_lname VARCHAR(255), 
    IN p_homeworld INT, 
    IN p_age INT,
    OUT p_id INT)
BEGIN
    INSERT INTO bsg_people (fname, lname, homeworld, age) 
    VALUES (p_fname, p_lname, p_homeworld, p_age);

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
-- UPDATE bsg_people
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdatePerson;

DELIMITER //
CREATE PROCEDURE sp_UpdatePerson(IN p_id INT, IN p_homeworld INT, IN p_age INT)

BEGIN
    UPDATE bsg_people SET homeworld = p_homeworld, age = p_age WHERE id = p_id; 
END //
DELIMITER ;

-- #############################
-- DELETE bsg_people
-- #############################
DROP PROCEDURE IF EXISTS sp_DeletePerson;

DELIMITER //
CREATE PROCEDURE sp_DeletePerson(IN p_id INT)
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
        DELETE FROM bsg_cert_people WHERE pid = p_id;
        DELETE FROM bsg_people WHERE id = p_id;

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
-- UPDATE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateCustomer;

DELIMITER //
CREATE PROCEDURE sp_UpdateCustomer(
    IN p_id INT, 
    IN p_address VARCHAR(100), 
    IN p_contactemail VARCHAR(100))

BEGIN
    UPDATE bsg_people SET Address = p_address, ContactEmail = p_contactemail WHERE CustomerID = p_id; 
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
        DELETE FROM Orders WHERE p CustomerID = p_id;
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