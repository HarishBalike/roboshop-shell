#!/bin/bash

instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")
domain_name="harishbalike.online"
hosted_zone_id="Z013862017DKOONOMKNDC"
region="us-east-1"
sg_id="sg-08492f9229eff00e6"
subnet_id="subnet-039c946b04bc14df1"
image_id="ami-041e2ea9402c46c32"

for name in ${instances[@]} ;do

  if [ $name == "mysql" ] || [ $name == "shipping" ] 
  
  then
    instance_type="t3.medium"
  else
   instance_type="t3.micro"

  fi

  echo "Creating instances for $name with instance type $instance_type"

  instance_id=$(aws ec2 run-instances --image-id $image_id  --instance-type $instance_type --security-group-ids $sg_id --subnet-id $subnet_id  --query "Instances[0].InstanceId" --output text)

  echo "Instance created for: $name"

  aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$name
  
  if [ $name == "web" ] 

  then
   
  public_ip=$(aws --region $region ec2 describe-instances  --query 'Reservations[0].Instances[0].[PublicIpAddress]' --output text)
  ip_to_use=$public_ip

  else

  private_ip=$(aws --region $region ec2 describe-instances  --query 'Reservations[0].Instances[0].[PrivateIpAddress]' --output text)
  ip_to_use=$private_ip

  fi

  aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id  --change-batch '
    {
        "Comment": "Creating a record set for '$name'"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$name.$domain_name'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$ip_to_use'"
            }]
        }
        }]
    }'
  

done