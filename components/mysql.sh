source components/common.sh

CHECK_ROOT

PRINT "Download Yum repos"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install mysql"
yum install mysql-community-server -y &>>${LOG}
systemctl enable mysqld &>>${LOG} && systemctl start mysqld &>>${LOG}
CHECK_STAT $?

MYSQL_DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

PRINT "Reset mysql password"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" | mysql --connect-expired-password -uroot -p"${MYSQL_DEFAULT_PASSWORD}" &>>${LOG}
CHECK_STAT $?

exit
echo "uninstall plugin validate_password;" | mysql -uroot -p"${MYSQL_PASSWORD}"
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
cd /tmp
unzip -o mysql.zip
cd mysql-main
mysql -u root -p"${MYSQL_PASSWORD}" < shipping.sql