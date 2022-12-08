source components/common.sh

CHECK_ROOT

curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
CHECK_STAT

yum install nodejs -y
CHECK_STAT

useradd roboshop
CHECK_STAT

curl -s -L -o /tmp/cart.zip "https://github.com/roboshop-devops-project/cart/archive/main.zip"
CHECK_STAT

cd /home/roboshop

rm -rf cart
CHECK_STAT

unzip /tmp/cart.zip
CHECK_STAT

mv cart-main cart
cd cart

npm install
CHECK_STAT

mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service
CHECK_STAT

sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /etc/systemd/system/cart.service
CHECK_STAT

systemctl daemon-reload
systemctl enable cart

systemctl restart cart
CHECK_STAT
