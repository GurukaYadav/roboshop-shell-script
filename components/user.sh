curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
yum install nodejs -y

useradd roboshop

curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip"
cd /home/roboshop
rm -rf user
unzip /tmp/user.zip
mv user-main user
cd /home/roboshop/user
npm install


mv /home/roboshop/user/systemd.service /etc/systemd/system/user.service
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /etc/systemd/system/user.service
systemctl daemon-reload
systemctl start user
systemctl enable user
