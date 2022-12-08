source components/common.sh

CHECK_ROOT

PRINT "Install NodeJS repos"
curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash &>>${LOG}
CHECK_STAT $?

PRINT "Install NodeJS"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Creating application user"
useradd roboshop &>>${LOG}
CHECK_STAT $?

PRINT "Downloading cart content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" &>>${LOG}
CHECK_STAT $?

cd /home/roboshop

PRINT "Removing previous cart content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Extracting cart content"
unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT $?

mv cart-main cart
cd cart

PRINT "Install NodeJS dependencies"
npm install &>>${LOG}
CHECK_STAT $?

PRINT "Setup SystemD configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?

PRINT "Update systemd configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?

systemctl daemon-reload
systemctl enable cart

PRINT "Start cart service"
systemctl restart cart &>>${LOG}
CHECK_STAT $?
