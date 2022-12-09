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

NODEJS() {
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
 fi
 CHECK_STAT $?

 PRINT "Download ${COMPONENT} content"
 curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG}
 CHECK_STAT $?

 cd /home/roboshop &>>${LOG}

 PRINT "Remove old ${COMPONENT} content"
 rm -rf ${COMPONENT} &>>${LOG}
 CHECK_STAT $?

 PRINT "Extract ${COMPONENT} content"
 unzip /tmp/${COMPONENT}.zip &>>${LOG}
 CHECK_STAT $?

 mv ${COMPONENT}-main ${COMPONENT}
 cd ${COMPONENT}

 PRINT "Install NodeJS dependencies"
 npm install &>>${LOG}
 CHECK_STAT $?

 PRINT "Update systemD configuration"
 sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/'  -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/'  -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG}
 CHECK_STAT $?

 PRINT "Setup systemD configuration"
 mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG}
 CHECK_STAT $?

 systemctl daemon-reload
 systemctl enable ${COMPONENT} &>>${LOG}

 PRINT "Start ${COMPONENT} service"
 systemctl restart ${COMPONENT} &>>${LOG}
 CHECK_STAT $?
}