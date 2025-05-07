
# Installing From Git
### To install the website files from github:

git clone https://github.com/ElliotOusley/DamDataMinersTeam75.git

### To set up the venv folder:

./venv-install.sh

#### OR

python3 -m venv ./venv

source venv/bin/activate

pip3 install Flask flask-mysqldb

pip3 install gunicorn

### To get the server running:

gunicorn -b 0.0.0.0:54535 -D app:app

### To close all active gunicorn servers:

pkill -u yourONID gunicorn

### To close a session:
deactivate
