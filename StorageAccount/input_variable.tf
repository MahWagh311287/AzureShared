# define variable
variable "myvar" {
  description = "This port the server will use for http request"
  type = number
}

# conigure provider
provider "aws" {
	region = "us-east-1"
	access_key = ""
	secret_key = ""
	}

# create security group
resource "aws_security_group" "instance" {
	name = "MySecGroup"
	ingress {
	from_port = var.myvar
	to_port = var.myvar
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	}
}

# deploy EC2
resource "aws_instance" "VM1" {
	ami = "ami-0261755bbcb8c4a84"
	instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id] 
	user_data =<<-EOF
	#!/bin/bash
	echo "Welcome to Terraform World" > index.html
	nohup busybox httpd -f -p ${var.myvar} &
	EOF

	user_data_replace_on_change = true

  tags = {
    Name = "devops"
  }
}

output "public_ip" {
  description = "The public ip of the web server"
  value = "aws_instance_VM1.public_ip"
}
