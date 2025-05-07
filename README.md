
# Installing From Git
### To install the website files from github, run the following command:

git clone https://github.com/ElliotOusley/DamDataMinersTeam75.git

### To set up the venv folder, run:

python3 -m venv ./venv

source venv/bin/activate

pip3 install Flask flask-mysqldb

pip3 install gunicorn

### To get the server running, run

gunicorn -b 0.0.0.0:54535 -D app:app

### To close all active gunicorn servers, run

pkill -u yourONID gunicorn

### To close a session, run
deactivate
