USER_ID=$(id -u)
if [$USER_ID -ne 0]; then
	echo You are Non Root user
	echo You can run this script with Root user or with sudo
	exit 1
fi

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
yum install erlang -y

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
yum install rabbitmq-server -y
systemctl enable rabbitmq-server
systemctl start rabbitmq-server


rabbitmqctl add_user roboshop "${RABBITMQ_PASSWORD}"
rabbitmqctl set_user_tags roboshop administrator
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"