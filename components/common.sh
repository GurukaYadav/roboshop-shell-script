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
echo "-------------------------"
 if [ $1 -ne 0 ]; then
 	echo -e "\e[31mFailure\e[0m"
 	echo -e "\nRefer logs-${LOG} for errors\n"
   	exit 2
 else
 	echo -e "\e[32mSuccess\e[0m"
 fi
}

PRINT() {
 echo "-------------$1------------"
 echo "$1"
}