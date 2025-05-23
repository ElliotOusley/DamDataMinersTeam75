from flask import Flask, render_template, request, redirect, url_for
import database.db_connector as db

PORT = 54535
app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    try:
        return render_template("home.j2")

    except Exception as e:
        print(f"Error rendering page: {e}")
        return "An error occurred while rendering the page.", 500
    
@app.route("/bsg-people", methods=["GET"])
def bsg_people():
    try:
        dbConnection = db.connectDB()  # Open our database connection

        # Create and execute our queries
        # In query1, we use a JOIN clause to display the names of the homeworlds,
        #       instead of just ID values
        query1 = "SELECT bsg_people.id, bsg_people.fname, bsg_people.lname, \
            bsg_planets.name AS 'homeworld', bsg_people.age FROM bsg_people \
            LEFT JOIN bsg_planets ON bsg_people.homeworld = bsg_planets.id;"
        query2 = "SELECT * FROM bsg_planets;"
        people = db.query(dbConnection, query1).fetchall()
        homeworlds = db.query(dbConnection, query2).fetchall()

        # Render the bsg-people.j2 file, and also send the renderer
        # a couple objects that contains bsg_people and bsg_homeworld information
        return render_template(
            "bsg-people.j2", people=people, homeworlds=homeworlds
        )

    except Exception as e:
        print(f"Error executing queries: {e}")
        return "An error occurred while executing the database queries.", 500

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()

@app.route("/customers", methods=["GET"])
def customers():
    try:
        dbConnection = db.connectDB()
        query = "SELECT * FROM Customers;"
        customers_data = db.query(dbConnection, query).fetchall()
        return render_template("customers.j2", customers=customers_data)
    except Exception as e:
        print(f"Error occurred with database queries", 500)
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()



@app.route("/products", methods=["GET"])
def products():
    try:
        dbConnection = db.connectDB()
        query = """
            SELECT 
                Products.ProductID, 
                Products.Name, 
                Products.Category, 
                Products.PricePerUnit, 
                Products.Quantity, 
                Products.IsSeasonal, 
                Products.SupplierID,
                Suppliers.Name AS SupplierName
            FROM Products
            JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID;
        """
        products_data = db.query(dbConnection, query).fetchall()
        return render_template("products.j2", products=products_data)
    except Exception as e:
        print(f"Error occurred with database queries", 500)
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()

@app.route("/orders", methods=["GET"])
def orders():
    try:
        dbConnection = db.connectDB()
        query = """
            SELECT 
                Orders.OrderID,
                Orders.OrderDate,
                Orders.OrderStatus,
                Orders.CustomerID,
                Customers.Name AS CustomerName
            FROM Orders
            JOIN Customers ON Orders.CustomerID = Customers.CustomerID;
        """
        orders_data = db.query(dbConnection, query).fetchall()
        return render_template("orders.j2", orders=orders_data)
    except Exception as e:
        print(f"Error occurred with database queries", 500)
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()

@app.route("/orderitems", methods=["GET"])
def orderitems():
    try:
        dbConnection = db.connectDB()
        query = """
            SELECT 
                OrderItems.OrderItemsID,
                Products.Name AS ProductName,
                Orders.OrderDate,
                OrderItems.Quantity,
                OrderItems.Price,
                OrderItems.OrderID,
                OrderItems.ProductID
            FROM OrderItems
            JOIN Products ON OrderItems.ProductID = Products.ProductID
            JOIN Orders ON OrderItems.OrderID = Orders.OrderID;
        """
        orderitems_data = db.query(dbConnection, query).fetchall()
        return render_template("orderitems.j2", orderitems=orderitems_data)
    except Exception as e:
        print(f"Error occurred with database queries", 500)
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()

@app.route("/suppliers", methods=["GET"])
def suppliers():
    try:
        dbConnection = db.connectDB()
        query = "SELECT * FROM Suppliers;"
        suppliers_data = db.query(dbConnection, query).fetchall()
        return render_template("suppliers.j2", suppliers=suppliers_data)
    except Exception as e:
        print(f"Error occurred with database queries", 500)
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()

@app.route("/reviews", methods=["GET"])
def reviews():
    try:
        dbConnection = db.connectDB()
        query = """
            SELECT 
                Reviews.ReviewID,
                Reviews.ReviewDate,
                Reviews.Rating,
                Reviews.Comment,
                Customers.Name AS CustomerName,
                Products.Name AS ProductName
            FROM Reviews
            JOIN Customers ON Reviews.CustomerID = Customers.CustomerID
            JOIN Products ON Reviews.ProductID = Products.ProductID;
        """
        reviews_data = db.query(dbConnection, query).fetchall()
        return render_template("reviews.j2", reviews=reviews_data)
    except Exception as e:
        print(f"Error occurred with database queries", 500)
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()

@app.route("/home/reset", methods=["POST"])
def reset_data():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        query1 = "CALL ResetAll();"

        cursor.execute(query1)

        cursor.nextset()

        dbConnection.commit()

        print(f"Database successfully reset")

        return redirect(url_for("home"))

    except Exception as e:
        print(f"Error occured when attempting reset", 500)
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


## CUSTOMERS
@app.route("/customers/create", methods=["POST"])
def create_customers():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        name = request.form["create_customer_name"]
        species = request.form["create_customer_species"]
        contactemail = request.form["create_customer_email"]


        # Cleanse data - If the homeworld or age aren't numbers, make them NULL.
        try:
            address = (request.form["create_customer_address"])
        except ValueError:
            address = None

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_CreateCustomer(%s, %s, %s, %s, @new_id);"
        cursor.execute(query1, (name, species, address, contactemail))

        # Store ID of last inserted row
        new_id = cursor.fetchone()[0]

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        print(f"CREATE Customer. ID: {new_id} Name: {name} Species: {species}")

        # Redirect the user to the updated webpage
        return redirect("/customers")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()

# UPDATE ROUTES
@app.route("/customers/update", methods=["POST"])
def update_customers():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        customer_id = request.form["update_customer_id"]
        contactemail = request.form["update_customer_email"]

        # Cleanse data - If the homeworld or age aren't numbers, make them NULL.
        try:
            address = (request.form["update_customer_address"])
        except ValueError:
            address = None

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_UpdateCustomer(%s, %s, %s);"
        cursor.execute(query1, (customer_id, address, contactemail))

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        # Redirect the user to the updated webpage
        return redirect("/customers")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


# DELETE ROUTES
@app.route("/customers/delete", methods=["POST"])
def delete_customers():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        customer_id = request.form["delete_customer_id"]
        customer_name = request.form["delete_customer_name"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteCustomer(%s);"
        cursor.execute(query1, (customer_id,))

        dbConnection.commit()  # commit the transaction

        print(f"DELETE customer. ID: {customer_id} Name: {customer_name}")

        # Redirect the user to the updated webpage
        return redirect("/customers")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()







if __name__ == "__main__":
    app.run(port=PORT, debug=True)