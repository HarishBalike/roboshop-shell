#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
      echo -e "$2....$R FAILURE $N"
      exit 1
    else
      echo -e "$2....$G SUCCESS $N"
    fi 

}

if [ $USERID -ne 0 ]
then
 echo "Please run this script with root access..."
 exit 1
else
  echo "You are super user.."
fi

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf  &>> $LOG_FILE
VALIDATE $? "Remote server access"

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>> $LOG_FILE
VALIDATE $? "Starting Redis"