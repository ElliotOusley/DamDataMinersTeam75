from flask import Flask, render_template, request, redirect, url_for
import database.db_connector as db

# Citation for the following code:
# Date: 5/22/25
# Adapted From Exploration - Web Application Technology
# Used to set up website
# Source URL: https://canvas.oregonstate.edu/courses/1999601/pages/exploration-web-application-technology-2?module_item_id=25352948

# Citation for the following code:
# Date: 5/22/25
# Adapted From Exploration - Implementing CUD operations in your app
# Used to set up website
# Source URL: https://canvas.oregonstate.edu/courses/1999601/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25352968




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
        
        query2 = "SELECT * FROM Suppliers;"
        suppliers_data = db.query(dbConnection, query2).fetchall()
        
        return render_template("products.j2", products=products_data, suppliers=suppliers_data)
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

        query2 = "SELECT * FROM Customers;"
        customers_data = db.query(dbConnection, query2).fetchall()

        return render_template("orders.j2", orders=orders_data, customers=customers_data)
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

        query2 = "SELECT * FROM Orders;"
        orders_data = db.query(dbConnection, query2).fetchall()

        query3 = "SELECT * FROM Products;"
        products_data = db.query(dbConnection, query3).fetchall()

        return render_template("orderitems.j2", orderitems=orderitems_data, orders=orders_data, products=products_data)
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

        query2 = "SELECT * FROM Customers;"
        customers_data = db.query(dbConnection, query2).fetchall()

        query3 = "SELECT * FROM Products;"
        products_data = db.query(dbConnection, query3).fetchall()

        return render_template("reviews.j2", reviews=reviews_data, customers=customers_data, products=products_data)
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

## CREATE ROUTES
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

## SUPPLIERS
@app.route("/suppliers/create", methods=["POST"])
def create_suppliers():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        name = request.form["create_supplier_name"]
        contactemail = request.form["create_supplier_email"]
        location = request.form["create_supplier_location"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_CreateSupplier(%s, %s, %s, @new_id);"
        cursor.execute(query1, (name, contactemail, location))

        # Store ID of last inserted row
        new_id = cursor.fetchone()[0]

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        print(f"CREATE Supplier. ID: {new_id} Name: {name} Email: {contactemail}")

        # Redirect the user to the updated webpage
        return redirect("/suppliers")

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

## PRODUCTS
@app.route("/products/create", methods=["POST"])
def create_products():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        name = request.form["create_product_name"]
        category = request.form["create_product_category"]
        ppu = request.form["create_product_price"]
        quantity = request.form["create_product_quantity"]
        seasonal = request.form["create_product_isseasonal"]
        supplier = request.form["create_product_supplier"]


        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_CreateProduct(%s, %s, %s, %s, %s, %s, @new_id);"
        cursor.execute(query1, (name, category, ppu, quantity, seasonal, supplier))

        # Store ID of last inserted row
        new_id = cursor.fetchone()[0]

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        print(f"CREATE Product. ID: {new_id} Name: {name} Category: {category}")

        # Redirect the user to the updated webpage
        return redirect("/products")

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

## ORDER
@app.route("/orders/create", methods=["POST"])
def create_orders():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        date = request.form["create_order_date"]
        status = request.form["create_order_status"]
        customer_id = request.form["create_order_customer"]


        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_CreateOrder(%s, %s, %s, @new_id);"
        cursor.execute(query1, (date, status, customer_id))

        # Store ID of last inserted row
        new_id = cursor.fetchone()[0]

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        print(f"CREATE Order. ID: {new_id} Date: {date} Customer Id: {customer_id}")

        # Redirect the user to the updated webpage
        return redirect("/orders")

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

## ORDERITEM
@app.route("/orderitems/create", methods=["POST"])
def create_orderitems():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        product_id = request.form["create_orderitem_product"]
        order_id = request.form["create_orderitem_order"]
        quantity = request.form["create_orderitem_quantity"]
        price = request.form["create_orderitem_price"]



        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_CreateOrderitem(%s, %s, %s, %s, @new_id);"
        cursor.execute(query1, (product_id, order_id, quantity, price))

        # Store ID of last inserted row
        new_id = cursor.fetchone()[0]

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        print(f"CREATE Order. ID: {new_id} Product ID: {product_id} Order Id: {order_id}")

        # Redirect the user to the updated webpage
        return redirect("/orderitems")

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
            
## REVIEWS
@app.route("/reviews/create", methods=["POST"])
def create_reviews():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        # Get form data
        review_date = request.form["create_review_date"]
        rating = request.form["create_review_rating"]
        comment = request.form["create_review_comment"]
        customer_id = request.form["create_review_customer"]
        product_id = request.form["create_review_product"]

        query = "CALL sp_CreateReview(%s, %s, %s, %s, %s, @new_id);"
        cursor.execute(query, (customer_id, review_date, rating, comment, product_id))

        new_id = cursor.fetchone()[0]
        cursor.nextset()
        dbConnection.commit()

        print(f"CREATE Review. ID: {new_id} Rating: {rating} Product: {product_id}")

        return redirect("/reviews")

    except Exception as e:
        print(f"Error executing create_reviews: {e}")
        return "An error occurred.", 500
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


# UPDATE ROUTES
## CUSTOMERS
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

        dbConnection.commit()  # commit the transaction

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


## SUPPLIERS
@app.route("/suppliers/update", methods=["POST"])
def update_suppliers():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        supplier_id = request.form["update_supplier_id"]
        contactemail = request.form["update_supplier_email"]
        location = request.form["update_supplier_location"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_UpdateSupplier(%s, %s, %s);"
        cursor.execute(query1, (supplier_id, contactemail, location))

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        # Redirect the user to the updated webpage
        return redirect("/suppliers")

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


## PRODUCT
@app.route("/products/update", methods=["POST"])
def update_products():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        product_id = request.form["update_product_id"]
        ppu = request.form["update_product_price"]
        quantity = request.form["update_product_quantity"]
        seasonal = request.form["update_product_isseasonal"]
        supplier_id = request.form["update_product_supplier"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_UpdateProduct(%s, %s, %s, %s, %s);"
        cursor.execute(query1, (product_id, ppu, quantity, seasonal, supplier_id))

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        # Redirect the user to the updated webpage
        return redirect("/products")

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

## ORDER
@app.route("/orders/update", methods=["POST"])
def update_orders():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        order_id = request.form["update_order_id"]
        status = request.form["update_order_status"]
        customer = request.form["update_order_customer"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_UpdateOrder(%s, %s, %s);"
        cursor.execute(query1, (order_id, status, customer))

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        # Redirect the user to the updated webpage
        return redirect("/orders")

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

## ORDERItem
@app.route("/orderitems/update", methods=["POST"])
def update_orderitems():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        orderitem_id = request.form["update_orderitem_id"]
        quantity = request.form["update_orderitem_quantity"]
        price = request.form["update_orderitem_price"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_UpdateOrderitem(%s, %s, %s);"
        cursor.execute(query1, (orderitem_id, quantity, price))

        # Consume the result set (if any) before running the next query
        cursor.nextset()  # Move to the next result set (for CALL statements)

        dbConnection.commit()  # commit the transaction

        # Redirect the user to the updated webpage
        return redirect("/orderitems")

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

## REVIEWS
@app.route("/reviews/update", methods=["POST"])
def update_reviews():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        review_id = request.form["update_review_id"]
        rating = request.form["update_review_rating"]
        comment = request.form["update_review_comment"]

        query = "CALL sp_UpdateReview(%s, %s, %s);"
        cursor.execute(query, (review_id, rating, comment))

        cursor.nextset()
        dbConnection.commit()

        return redirect("/reviews")

    except Exception as e:
        print(f"Error executing update_reviews: {e}")
        return "An error occurred.", 500
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


# DELETE ROUTES
## CUSTOMERS
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

## SUPPLIERS
@app.route("/suppliers/delete", methods=["POST"])
def delete_suppliers():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        supplier_id = request.form["delete_supplier_id"]
        supplier_name = request.form["delete_supplier_name"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteSupplier(%s);"
        cursor.execute(query1, (supplier_id,))

        dbConnection.commit()  # commit the transaction

        print(f"DELETE customer. ID: {supplier_id} Name: {supplier_name}")

        # Redirect the user to the updated webpage
        return redirect("/suppliers")

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


## PRODUCTS
@app.route("/products/delete", methods=["POST"])
def delete_products():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        product_id = request.form["delete_product_id"]
        product_name = request.form["delete_product_name"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteProduct(%s);"
        cursor.execute(query1, (product_id,))

        dbConnection.commit()  # commit the transaction

        print(f"DELETE customer. ID: {product_id} Name: {product_name}")

        # Redirect the user to the updated webpage
        return redirect("/products")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists.
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


## Orders
@app.route("/orders/delete", methods=["POST"])
def delete_orders():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        order_id = request.form["delete_order_id"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteOrder(%s);"
        cursor.execute(query1, (order_id,))

        dbConnection.commit()  # commit the transaction

        print(f"DELETE customer. ID: {order_id}")

        # Redirect the user to the updated webpage
        return redirect("/orders")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists.
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()


## Orderitems
@app.route("/orderitems/delete", methods=["POST"])
def delete_orderitems():
    try:
        dbConnection = db.connectDB()  # Open our database connection
        cursor = dbConnection.cursor()

        # Get form data
        orderitem_id = request.form["delete_orderitem_id"]

        # Create and execute our queries
        # Using parameterized queries (Prevents SQL injection attacks)
        query1 = "CALL sp_DeleteOrderitem(%s);"
        cursor.execute(query1, (orderitem_id,))

        dbConnection.commit()  # commit the transaction

        print(f"DELETE orderitem ID: {orderitem_id}")

        # Redirect the user to the updated webpage
        return redirect("/orderitems")

    except Exception as e:
        print(f"Error executing queries: {e}")
        return (
            "An error occurred while executing the database queries.",
            500,
        )

    finally:
        # Close the DB connection, if it exists.
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()
## REVIEWS
@app.route("/reviews/delete", methods=["POST"])
def delete_reviews():
    try:
        dbConnection = db.connectDB()
        cursor = dbConnection.cursor()

        review_id = request.form["delete_review_id"]

        query = "CALL sp_DeleteReview(%s);"
        cursor.execute(query, (review_id,))

        dbConnection.commit()

        print(f"DELETE Review. ID: {review_id}")
        return redirect("/reviews")

    except Exception as e:
        print(f"Error executing delete_reviews: {e}")
        return "An error occurred.", 500
    finally:
        if "dbConnection" in locals() and dbConnection:
            dbConnection.close()




if __name__ == "__main__":
    app.run(port=PORT, debug=True)