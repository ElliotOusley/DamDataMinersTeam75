from flask import Flask, render_template
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

if __name__ == "__main__":
    app.run(port=PORT, debug=True)