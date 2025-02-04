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

dnf install golang -y

useradd roboshop

mkdir /app 

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip

cd /app

unzip /tmp/dispatch.zip


go mod init dispatch

go get 

go build

cp /home/ec2-user/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service

systemctl daemon-reload

systemctl enable dispatch

systemctl start dispatch