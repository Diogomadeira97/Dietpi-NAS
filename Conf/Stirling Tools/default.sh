sudo apt-get update
sudo apt-get install -y git automake autoconf libtool \
    libleptonica-dev pkg-config zlib1g-dev make g++ \
    openjdk-21-jdk python3 python3-pip

mkdir ~/.git
cd ~/.git &&\
git clone https://github.com/agl/jbig2enc.git &&\
cd jbig2enc &&\
./autogen.sh &&\
./configure &&\
make &&\
sudo make install

sudo apt-get install -y libreoffice-writer libreoffice-calc libreoffice-impress tesseract
pip3 install uno opencv-python-headless unoconv pngquant WeasyPrint --break-system-packages

cd ~/.git &&\
git clone https://github.com/Stirling-Tools/Stirling-PDF.git &&\
cd Stirling-PDF &&\
chmod +x ./gradlew &&\
./gradlew build

#root
sudo mkdir /opt/Stirling-PDF &&\
sudo mv ./build/libs/Stirling-PDF-*.jar /opt/Stirling-PDF/ &&\
sudo mv scripts /opt/Stirling-PDF/ &&\
echo "Scripts installed."

#Nonroot
mv ./build/libs/Stirling-PDF-*.jar ./Stirling-PDF-*.jar

sudo apt update &&\
# All languages
# sudo apt install -y 'tesseract-ocr-*'

# Find languages:
apt search tesseract-ocr-

# View installed languages:
dpkg-query -W tesseract-ocr- | sed 's/tesseract-ocr-//g'

java -jar /opt/Stirling-PDF/Stirling-PDF-*.jar

mkdir temp
export DBUS_SESSION_BUS_ADDRESS="unix:path=./temp"

touch /opt/Stirling-PDF/.env

nano /etc/systemd/system/stirlingpdf.service

[Unit]
Description=Stirling-PDF service
After=syslog.target network.target

[Service]
SuccessExitStatus=143

User=root
Group=root

Type=simple

EnvironmentFile=/opt/Stirling-PDF/.env
WorkingDirectory=/opt/Stirling-PDF
ExecStart=/usr/bin/java -jar Stirling-PDF-0.17.2.jar
ExecStop=/bin/kill -15 $MAINPID

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload

sudo systemctl enable stirlingpdf.service