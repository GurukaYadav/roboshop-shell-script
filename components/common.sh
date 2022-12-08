CHECK_ROOT() {
 USER_ID=$(id -u)
 if [ $USER_ID -ne 0 ]; then
	echo -e "\e[31mYou should be running this script as Root user or Sudo this script\e[0m"
	exit 1
 fi
}

LOG=/tmp/roboshop.log
rm -f ${LOG}

CHECK_STAT() {
 if [ $? -ne 0 ]; then
 	echo "failed"
   	exit 2
 else
 	echo "success"
 fi
}