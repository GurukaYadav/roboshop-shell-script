source components/common.sh

CHECK_ROOT

if [ -z "${RABBITMQ_USER_PASSWORD}"]; then
	echo "Env Variable RABBITMQ_USER_PASSWORD needed"
fi

PRINT "Download erlang repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash  &>>${LOG}
CHECK_STAT $?

PRINT "Install erlang"
yum install erlang -y &>>${LOG}
CHECK_STAT $?

PRINT "Download rabbitmq repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash  &>>${LOG}
CHECK_STAT $?

PRINT "Install rabbitmq"
yum install rabbitmq-server -y &>>${LOG}
CHECK_STAT $?

PRINT "Start rabbitmq"
systemctl enable rabbitmq-server &>>${LOG} && systemctl restart rabbitmq-server &>>${LOG}
CHECK_STAT $?

PRINT "rabbitmq user"
rabbitmqctl add_user roboshop "${RABBITMQ_USER_PASSWORD}" &>>${LOG}
CHECK_STAT $?

PRINT "setup user tags and permissions"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
CHECK_STAT $?
