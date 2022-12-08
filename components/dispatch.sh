USER_ID=$(id -u)
if [$USER_ID -ne 0]; then
	echo You are Non Root user
	echo You can run this script with Root user or with sudo
	exit 1
fi

yum install golang -y

useradd roboshop

curl -L -s -o /tmp/dispatch.zip https://github.com/roboshop-devops-project/dispatch/archive/refs/heads/main.zip
unzip -o /tmp/dispatch.zip
mv dispatch-main dispatch
cd dispatch
go mod init dispatch
go get
go build

mv /home/roboshop/dispatch/systemd.service  /etc/systemd/system/dispatch.service
sed -i -e 's/AMQPHOST/rabbitmq.roboshop.internal/'  /etc/systemd/system/dispatch.service
systemctl daemon-reload
systemctl enable dispatch
systemctl restart dispatch