/*
    SETUP
*/

// Express
const express = require('express');  // We are using the express library for the web server
const app = express();               // We need to instantiate an express object to interact with the server in our code
const PORT = 54221;     // Set a port number

// Database 
const db = require('./db-connector.js');


/*
    ROUTES
*/

app.get('/', async function (req, res) {
    try {
        
        // Define our queries
        const query1 = 'DROP TABLE IF EXISTS diagnostic;';
        const query2 = 'CREATE TABLE diagnostic(id INT PRIMARY KEY AUTO_INCREMENT, text VARCHAR(255) NOT NULL);';
        const query3 = 'INSERT INTO diagnostic (text) VALUES ("MySQL and Node is working for ousleye!");'; // Replace with your ONID
        const query4 = 'SELECT * FROM diagnostic;';
        
        // Execute each query synchronously (await).
        // We want each query to finish before the next one starts.
        await db.query(query1);
        await db.query(query2);
        await db.query(query3);
        const [rows] = await db.query(query4); // Store the results
        
        // Send the results to the browser
        const base = "<h1>MySQL Results:</h1>";
        res.send(base + JSON.stringify(rows));

    } catch (error) {
        console.error("Error executing queries:", error);

        // Send a generic error message to the browser
        res.status(500).send("An error occurred while executing the database queries.");
    }
});


/*
    LISTENER
*/

app.listen(PORT, function(){            // This is the basic syntax for what is called the 'listener' which receives incoming requests on the specified PORT.
    console.log('Express started on http://localhost:' + PORT + '; press Ctrl-C to terminate.')
});