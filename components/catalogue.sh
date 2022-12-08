USER_ID=$(id -u)
if [$USER_ID -ne 0]; then
	echo You are Non Root user
	echo You can run this script with Root user or with sudo
	exit 1
fi

curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
yum install nodejs -y

useradd roboshop

curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip"
cd /home/roboshop
rm -rf catalogue
unzip /tmp/catalogue.zip
mv catalogue-main catalogue
cd /home/roboshop/catalogue
npm install


mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/'  /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl restart catalogue
systemctl enable catalogue

