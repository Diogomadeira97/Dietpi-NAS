#Install postgresql.
sudo apt-get install postgresql -y

#Create user and database.
sudo -i -u postgres psql -c "CREATE USER onlyoffice WITH PASSWORD "$(echo "$1")";"
sudo -i -u postgres psql -c "CREATE DATABASE onlyoffice OWNER onlyoffice;"

#Install rabbitmq-server.
sudo apt-get install rabbitmq-server

#Change port to 8090
echo onlyoffice-documentserver onlyoffice/ds-port select 8090 | sudo debconf-set-selections

#Add GPG key.
mkdir -p -m 700 ~/.gnupg
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg

#Add ONLYOFFICE Docs repository.
echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list

#Update
sudo apt-get update

#Install ttf-mscorefonts-installer.
sudo apt-get install ttf-mscorefonts-installer -y

#Install Onlyoffice.
sudo apt-get install onlyoffice-documentserver -y