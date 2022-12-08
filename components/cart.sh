source components/common.sh

CHECK_ROOT

curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash &>>${LOG}
CHECK_STAT

yum install nodejs -y &>>${LOG}
CHECK_STAT

useradd roboshop &>>${LOG}
CHECK_STAT

curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip" &>>${LOG}
CHECK_STAT

cd /home/roboshop

rm -rf cart &>>${LOG}
CHECK_STAT

unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT

mv cart-main cart
cd cart

npm install &>>${LOG}
CHECK_STAT

mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT

sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT

systemctl daemon-reload
systemctl enable cart

systemctl restart cart &>>${LOG}
CHECK_STAT
