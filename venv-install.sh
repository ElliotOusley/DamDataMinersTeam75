#!/bin/bash

echo "Setting up the venv folder"
python3 -m venv ./venv
sleep 5

source venv/bin/activate
sleep 5

pip3 install Flask flask-mysqldb
sleep 5

pip3 install gunicorn
sleep 5

echo "Venv folder set up"
