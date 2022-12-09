source components/common.sh

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

PRINT "Update systemd configuration"
mv /home/roboshop/${COMPONENT}/systemd.service  /etc/systemd/system/${COMPONENT}.service &>>${LOG}
CHECK_STAT $?

PRINT "Setup systemd configuration"
sed -i -e 's/AMQPHOST/rabbitmq.roboshop.internal/'  /etc/systemd/system/${COMPONENT}.service &>>${LOG}
CHECK_STAT $?

PRINT "Start ${COMPONENT} service"
systemctl daemon-reload && systemctl enable ${COMPONENT} &>>${LOG} && systemctl restart ${COMPONENT} &>>${LOG}
CHECK_STAT $?