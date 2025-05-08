from flask import Flask, render_template
import database.db_connector as db

PORT = 54535
app = Flask(__name__)

@app.route("/")
def home():
    return render_template("home.j2")

@app.route("/customers")
def customers():
    return render_template("customers.j2")

@app.route("/products")
def products():
    return render_template("products.j2")

@app.route("/orders")
def orders():
    return render_template("orders.j2")

@app.route("/orderitems")
def orderitems():
    return render_template("orderitems.j2")

@app.route("/suppliers")
def suppliers():
    return render_template("suppliers.j2")

@app.route("/reviews")
def reviews():
    return render_template("reviews.j2")

if __name__ == "__main__":
    app.run(port=PORT, debug=True)

