source components/common.sh

CHECK_ROOT

if [ -z ${MYSQL_PASSWORD} ]; then
  echo "Need MYSQL_PASSWORD env variable"
  exit 1
fi

PRINT "Download Yum repos"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install mysql"
yum install mysql-community-server -y &>>${LOG}
systemctl enable mysqld &>>${LOG} && systemctl start mysqld &>>${LOG}
CHECK_STAT $?

MYSQL_DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

echo "show databases;" | mysql -uroot -p"${MYSQL_PASSWORD}" &>>${LOG}
if [ $? -ne 0 ]; then
  PRINT "Reset mysql password"
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" | mysql --connect-expired-password -uroot -p"${MYSQL_DEFAULT_PASSWORD}" &>>${LOG}
fi



echo "show plugins;" |  mysql -uroot -p"${MYSQL_PASSWORD}" | grep validate_password &>>${LOG}
if [ $? -eq 0 ]; then
  PRINT "Uninstall validate plugin"
  echo "uninstall plugin validate_password;" | mysql -uroot -p"${MYSQL_PASSWORD}"
fi

PRINT "Download Schema"
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>${LOG}
CHECK_STAT $?

PRINT "Load Schema"
cd /tmp && unzip -o mysql.zip &>>${LOG} && cd mysql-main && mysql -u root -p"${MYSQL_PASSWORD}" < shipping.sql &>>${LOG}
CHECK_STAT $?