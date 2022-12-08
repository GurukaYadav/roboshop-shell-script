USER_ID=$(id -u)
if [$USER_ID -ne 0]; then
	echo You are Non Root user
	echo You can run this script with Root user or with sudo
	exit 1
fi

yum install nginx -y
systemctl enable nginx
systemctl start nginx


curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip
mv frontend-main/static/* .
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf


sed -i -e '/catalogue/  s/localhost/catalogue.roboshop.internal/' -e '/user/  s/localhost/user.roboshop.internal/' -e '/cart/  s/localhost/cart.roboshop.internal/' -e '/shipping/  s/localhost/shipping.roboshop.internal/' -e '/payment/  s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf

systemctl restart nginx
