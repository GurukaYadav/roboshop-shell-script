CHECK_ROOT() {
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
	echo You are Non Root user
	echo You can run this script with Root user or with sudo
	exit 1
fi
}
