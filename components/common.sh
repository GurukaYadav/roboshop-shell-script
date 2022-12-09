CHECK_ROOT() {
 USER_ID=$(id -u)
 if [ $USER_ID -ne 0 ]; then
	echo -e "\e[31mYou should be running this script as Root user or Sudo this script\e[0m"
	exit 1
 fi
}

LOG=/tmp/roboshop.log
rm -rf ${LOG}

CHECK_STAT() {
echo "-------------------------" &>>${LOG}
 if [ $1 -ne 0 ]; then
 	echo -e "\e[31mFailure\e[0m"
 	echo -e "\nRefer logs-${LOG} for errors\n"
   	exit 2
 else
 	echo -e "\e[32mSuccess\e[0m"
 fi
}

PRINT() {
 echo "-------------$1------------" &>>${LOG}
 echo "$1"
}

APP_COMMON_SETUP(){
  PRINT "Create application user"
  id roboshop
  if [ $? -ne 0 ]; then
 	useradd roboshop &>>${LOG}
  fi
  CHECK_STAT $?

  PRINT "Download ${COMPONENT} content"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
  CHECK_STAT $?

  cd /home/roboshop

  PRINT "Remove old ${COMPONENT} content"
  rm -rf ${COMPONENT} &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract ${COMPONENT} content"
  unzip /tmp/${COMPONENT}.zip &>>${LOG}
  CHECK_STAT $?
}

SYSTEMD() {
  PRINT "Update systemd configuration"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG}
  CHECK_STAT $?

  PRINT "Setup systemd configuration"
  sed -i -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/'  -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/'  -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/'  -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/'  -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/'  /etc/systemd/system/${COMPONENT}.service &>>${LOG}
  CHECK_STAT $?

  PRINT "Start ${COMPONENT} service"
  systemctl daemon-reload && systemctl enable ${COMPONENT} &>>${LOG} && systemctl restart ${COMPONENT} &>>${LOG}
  CHECK_STAT $?
}


NODEJS() {
 CHECK_ROOT

 PRINT "Setting up NodeJS repository"
 curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash &>>${LOG}
 CHECK_STAT $?

 PRINT "Install NodeJS"
 yum install nodejs -y &>>${LOG}
 CHECK_STAT $?

 APP_COMMON_SETUP

 mv ${COMPONENT}-main ${COMPONENT}
 cd ${COMPONENT}

 PRINT "Install NodeJS dependencies"
 npm install &>>${LOG}
 CHECK_STAT $?

 SYSTEMD
}

NGINX() {
 CHECK_ROOT

 PRINT "Install nginx"
 yum install nginx -y &>>${LOG}
 CHECK_STAT $?

 PRINT "Download ${COMPONENT} content"
 curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
 CHECK_STAT $?

 cd /usr/share/nginx/html

 PRINT "Remove old content"
 rm -rf * &>>${LOG}
 CHECK_STAT $?

 PRINT "Organize ${COMPONENT} content"
 unzip /tmp/${COMPONENT}.zip &>>${LOG} && mv ${COMPONENT}-main/static/* . &>>${LOG} && mv ${COMPONENT}-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}
 CHECK_STAT $?

 PRINT "Setup systemd configuration"
 sed -i -e '/catalogue/  s/localhost/catalogue.roboshop.internal/' -e '/user/  s/localhost/user.roboshop.internal/' -e '/cart/  s/localhost/cart.roboshop.internal/' -e '/shipping/  s/localhost/shipping.roboshop.internal/' -e '/payment/  s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf &>>${LOG}
 CHECK_STAT $?

 PRINT "Start nginx service"
 systemctl enable nginx &>>${LOG} && systemctl restart nginx &>>${LOG}
 CHECK_STAT $?
}

PYTHON() {
 CHECK_ROOT

 PRINT "Install python 3"
 yum install python36 gcc python3-devel -y &>>${LOG}
 CHECK_STAT $?

 APP_COMMON_SETUP

 mv ${COMPONENT}-main ${COMPONENT}
 PRINT "Install python dependencies"
 cd /home/roboshop/${COMPONENT} && pip3 install -r requirements.txt &>>${LOG}
 CHECK_STAT $?

 USER_ID=$(id -u roboshop)
 GROUP_ID=$(id -g roboshop)

 PRINT "Update user and group id's"
 sed -i -e '/^uid/ c /uid=${USER_ID}/'  -e '/^gid/ c /gid=${GROUP_ID}/' /home/roboshop/${COMPONENT}/${COMPONENT}.ini
 CHECK_STAT $?

 SYSTEMD
}

MAVEN() {
 CHECK_ROOT

 PRINT "Install maven"
 yum install maven -y &>>${LOG}
 CHECK_STAT $?

 APP_COMMON_SETUP

 mv ${COMPONENT}-main ${COMPONENT}
 cd shipping

 PRINT "Install maven dependencies"
 mvn clean package &>>${LOG} && mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar &>>${LOG}
 CHECK_STAT $?

 SYSTEMD
}

GOLANG() {
 CHECK_ROOT

 PRINT "Install golang"
 yum install golang -y &>>${LOG}
 CHECK_STAT $?

 PRINT "Create application user"
 id roboshop
 if [ $? -ne 0 ]; then
   useradd roboshop &>>${LOG}
 fi
 CHECK_STAT $?


 PRINT "Download ${COMPONENT} content"
 curl -L -s -o /tmp/${COMPONENT}.zip https://github.com/roboshop-devops-project/${COMPONENT}/archive/refs/heads/main.zip &>>${LOG}
 CHECK_STAT $?

 cd /home/roboshop

 PRINT "Remove old ${COMPONENT} content"
 rm -rf ${COMPONENT} &>>${LOG}
 CHECK_STAT $?

 PRINT "Extract ${COMPONENT} content"
 unzip  /tmp/${COMPONENT}.zip &>>${LOG}
 CHECK_STAT $?

 mv dispatch-main ${COMPONENT}
 cd ${COMPONENT}

 PRINT "Install golang dependencies"
 go mod init ${COMPONENT} &>>${LOG} && go get &>>${LOG} && go build &>>${LOG}
 CHECK_STAT $?

 SYSTEMD
}