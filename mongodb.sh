#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="e\[31m"
G="e\[32m"
Y="e\[33m"
N="e\[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "Copied Mongo repo"

dnf install mongodb-org -y  &>> $LOG_FILE
VALIDATE $? "Installing mongoDB"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enabling mongoDB"
 
systemctl start mongod &>> $LOG_FILE
VALIDATE $? "Starting mongoDB"

sed -i '/s/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
VALIDATE $? "Remote server access"

systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "Restarting mongDB"