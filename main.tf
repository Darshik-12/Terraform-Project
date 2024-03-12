# --------------------Creating VPC--------------------

resource "aws_vpc" "VPC" {
  cidr_block = var.vpc_cidr
}

# Two Public Subnet

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id
}

# Route table for Route to Internet Gateway

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Subnet Association

resource "aws_route_table_association" "rta1" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.subnet1.id
}

resource "aws_route_table_association" "rta2" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.subnet2.id
}

# Security Group --> Internet Firewall

resource "aws_security_group" "sg" {
  name_prefix = "web-sg"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description = "HTTP Inbound Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH Inbound Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }
}

# --------------------Creating S3 Bucket--------------------

resource "aws_s3_bucket" "s3b" {
  bucket = "my-s3-buctet-darshik"

  tags = {
    Name = "my-s3-buctet-darshik"
  }
}

# resource "aws_s3_account_public_access_block" "public" {
#   block_public_acls   = false
#   block_public_policy = false
#   ignore_public_acls = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket = aws_s3_bucket.s3b.id

#   block_public_policy = false
#   block_public_acls   = false
# }

# resource "aws_s3_bucket_object" "object" {
#   bucket = "my-s3-buctet-darshik"
#   source = "C:\Users\dbmar\OneDrive\Desktop\EPGC_Cloud_Computing\Assignment_Material\S3.txt"
# }

# --------------------Creating EC2 Instance--------------------

resource "aws_instance" "server1" {
  ami                    = "ami-07d9b9ddc6cd8dd30"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  key_name               = "UbuntuK1"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = base64encode(file("userdata.sh"))
  iam_instance_profile   = aws_iam_instance_profile.EC2_Instance_Profile.name
}

resource "aws_instance" "server2" {
  ami                    = "ami-07d9b9ddc6cd8dd30"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  key_name               = "UbuntuK1"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = base64encode(file("userdata1.sh"))
  iam_instance_profile   = aws_iam_instance_profile.EC2_Instance_Profile.name
}

# --------------------Creating Elastic Application Load Balancer--------------------

# Application Load Balancer

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "ALB"
  }
}

# Target Group

resource "aws_lb_target_group" "tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# Attaching EC2 Instances in the Target Group

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.server2.id
  port             = 80
}

# Listener Port No.: 80(HTTP)

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Load Balancer DNS Name will be printed in the terminal

output "loadbalancerdns" {
  value = aws_lb.alb.dns_name
}

# --------------------Creating IAM Role--------------------

resource "aws_iam_role" "iam" {
  name = "AWS_EC2_with_S3_Full_access"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# IAM Role Policy

resource "aws_iam_policy" "policy" {
  name        = "S3-Bucket-Access-Policy"
  description = "Provides permission to access S3"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*",
            "s3-object-lambda:*"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

# Modifying EC2 Instances Role

resource "aws_iam_policy_attachment" "policy_attach" {
  name       = "EC2_Policy_Attachment"
  roles      = [aws_iam_role.iam.name]
  policy_arn = aws_iam_policy.policy.arn
}

# EC2 Instance Profile

resource "aws_iam_instance_profile" "EC2_Instance_Profile" {
  name = "Instance_Profile"
  role = aws_iam_role.iam.name
}




# Server 1 --> 54.174.27.166
# Server 2 --> 3.238.39.112
