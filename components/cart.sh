source components/common.sh

CHECK_ROOT

PRINT "Setting up NodeJS repository"
curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash &>>${LOG}
CHECK_STAT $?

PRINT "Install NodeJS"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Create application user"
id roboshop
if [ $? -ne 0 ]; then
	useradd roboshop &>>${LOG}
CHECK_STAT $?

PRINT "Download cart content"
curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" &>>${LOG}
CHECK_STAT $?

cd /home/roboshop &>>${LOG}

PRINT "Remove old cart content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Extract cart content"
unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT $?

mv cart-main cart
cd cart

PRINT "Install NodeJS dependencies"
npm install &>>${LOG}
CHECK_STAT $?

PRINT "Update systemD configuration"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/'  -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/'  /home/roboshop/cart/systemd.service &>>${LOG}
CHECK_STAT $?

PRINT "Setup systemD configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?

systemctl daemon-reload
systemctl enable cart

PRINT "Start cart service"
systemctl restart cart &>>${LOG}
CHECK_STAT $?

