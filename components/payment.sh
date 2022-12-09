source components/common.sh

CHECK_ROOT

PRINT "Install python 3"
yum install python36 gcc python3-devel -y &>>${LOG}
CHECK_STAT $?

PRINT "Create application user"
 id roboshop
 if [ $? -ne 0 ]; then
	useradd roboshop &>>${LOG}
 fi
 CHECK_STAT $?

cd /home/roboshop

PRINT "Remove old payment content"
rm -rf payment &>>${LOG}
CHECK_STAT $?

PRINT "Download payment content"
curl -L -s -o /tmp/payment.zip "https://github.com/roboshop-devops-project/payment/archive/main.zip" &>>${LOG}
CHECK_STAT $?

PRINT "Extract payment content"
unzip /tmp/payment.zip &>>${LOG}
CHECK_STAT $?

mv payment-main payment
PRINT "Install python dependencies"
cd /home/roboshop/payment && pip3 install -r requirements.txt &>>${LOG}
CHECK_STAT $?

USER_ID=$(id -u roboshop)
GROUP_ID=$(id -g roboshop)

PRINT "Update user and group id's"
sed -i -e '/^uid/ c /uid=${USER_ID}/'  -e '/^gid/ c /gid=${GROUP_ID}/' /home/roboshop/payment/payment.ini
CHECK_STAT $?

PRINT "Update systemd configuration"
mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service &>>${LOG}
CHECK_STAT $?

PRINT "Setup systemd configuration"
sed -i -e 's/CARTHOST/cart.roboshop.internal/'  -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/'  /etc/systemd/system/payment.service &>>${LOG}
CHECK_STAT $?

PRINT "Start payment service"
systemctl daemon-reload && systemctl enable payment &>>${LOG} && systemctl restart payment &>>${LOG}
