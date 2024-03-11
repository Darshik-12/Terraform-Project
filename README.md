
# Automate Infrastructure Using Terraform

This project aims to automate infrastructure provisioning and management using Terraform, a powerful infrastructure-as-code tool. By defining infrastructure requirements in Terraform configuration files, the project will enable seamless deployment and scaling of cloud resources AWS cloud providers. With Terraform's declarative syntax and support for multiple providers, the project seeks to streamline infrastructure management processes, improve efficiency, and ensure consistency in infrastructure deployments. Through this project, users will gain hands-on experience in Terraform usage and learn best practices for automating infrastructure tasks in a cloud environment.

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/f5011eca-171c-41f0-a75e-18fd4026ce35)

I am automating the infrastructure depicted in the above image using Terraform.

## Create VPC

- VPC stands for Virtual Private Cloud.
- A VPC is a virtual network environment within the cloud that allows users to launch resources, such as virtual machines and databases, in a customizable and isolated network space.
- It provides a high level of control over network configurations, including IP address ranges, subnets, route tables, and security settings.
- With a VPC, users can securely connect their cloud resources and extend their on-premises network into the cloud.
- VPCs are essential for building scalable and secure cloud-based applications and services, providing a foundation for network isolation, security, and efficient resource utilization.
- Here, I am utilizing Terraform to create a VPC, subnets, route tables, and an internet gateway.

```
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
```

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/1e0dfe1e-e392-48c0-9429-ac7db1a61425)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/d0d486b6-0db7-4768-b97b-324da10d233c)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/9913d576-a597-42a3-8b7a-5d61000c22c0)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/784b71b4-34b1-4f09-8f0e-5bf8d7a85247)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/06414a95-ce30-4777-b103-c27c3335a0d1)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/ea910779-4ea9-44ca-8df2-997ec82d4caf)


## Create Security Group

- A Security Group acts as a virtual firewall, controlling inbound and outbound traffic for AWS instances.
- By configuring rules in the Security Group, administrators can allow or deny traffic to and from AWS services, enhancing the security of their cloud environment.
- In this security group, I will configure inbound rules to allow SSH and HTTP traffic, while all outbound traffic will be allowed.

```
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
```

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/6f84ef17-3f17-489a-aa0c-92343a20c684)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/ad19b064-32a8-41ad-a063-8fadeb780277)


## Create S3 Bucket

- Amazon Simple Storage Service (S3) is a highly scalable object storage service offered by Amazon Web Services (AWS).
- It provides developers with a secure, durable, and highly available storage solution for a wide variety of use cases, including data storage, backup and recovery, website hosting, and data lakes.
- With S3, users can store and retrieve any amount of data at any time, from anywhere on the web.
- S3 offers several features such as versioning, encryption, access control, and lifecycle management to ensure data security, integrity, and compliance with regulatory requirements.
- It supports a range of storage classes to optimize costs and performance based on specific workload requirements.
- S3's simple and intuitive API makes it easy to integrate with applications and services, enabling seamless data management and access across the AWS ecosystem.

```
# --------------------Creating S3 Bucket--------------------

resource "aws_s3_bucket" "s3b" {
  bucket = "my-s3-buctet-darshik"

  tags = {
    Name = "my-s3-buctet-darshik"
  }
}
```

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/0391a1b2-87d0-4f05-ba1b-a5921c3143ac)


## Create EC2 Instance

- Amazon Elastic Compute Cloud (Amazon EC2) is a web service that provides resizable compute capacity in the cloud.
- It allows users to quickly scale computing resources up or down based on demand, paying only for the capacity they use.
- EC2 offers a wide selection of instance types optimized for different use cases, such as general-purpose, compute-optimized, memory-optimized, and storage-optimized instances.
- Users can choose from various operating systems and software configurations to customize their instances according to their requirements.
- EC2 instances are deployed in virtual private clouds (VPCs), providing users with complete control over their networking environment, including IP addresses, subnets, and security groups.
- Overall, EC2 enables businesses to deploy and manage virtual servers easily, making it a cornerstone service in building scalable and flexible cloud-based applications.

```
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
```

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/76026927-ac4e-40b4-9034-52d77a328747)


## Create ALB

- Application Load Balancer (ALB) is an AWS service that distributes incoming application traffic across multiple targets, such as EC2 instances, containers, and IP addresses, within AWS.
- ALB operates at the application layer (Layer 7) of the OSI model, allowing it to route requests based on content, hostname, path, and other application-level attributes.
- ALB supports advanced features like host-based and path-based routing, TLS termination, and native integration with AWS services like AWS Certificate Manager and AWS WAF.
- With its advanced routing capabilities and seamless integration with AWS infrastructure, ALB enables users to build highly scalable, fault-tolerant, and secure web applications on the AWS platform.

```
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
```

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/3579c96c-2ee1-425f-bbac-800e874cea20)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/da099c36-e36e-4007-bb54-f345b0acc000)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/0efe00da-b234-4df1-8a7d-12c9032271bc)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/a77162a5-0470-4fdd-b620-f32e29470b2e)



## Create IAM Role

AWS Identity and Access Management (IAM) is a service that enables secure control over access to AWS resources.
- It allows users to manage users, groups, roles, and their associated permissions within their AWS account.
- IAM enables fine-grained access control, allowing users to grant or deny permissions based on specific actions or resources.
- It also supports multi-factor authentication (MFA) and integrates with various AWS services for enhanced security.
- IAM is essential for maintaining the principle of least privilege and ensuring compliance with security best practices in AWS environments.
- IAM role for allowing full access of S3 Bucket to the EC2 Instance.
- For this purpose, I first created an IAM role with full access to Amazon S3. Then, I created an S3 Full Access policy for the IAM role. Finally, I added the role to an EC2 instance using an instance profile. This setup allows the EC2 instance to access S3 resources with the permissions granted by the IAM role.

```
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
```

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/d6a1db9f-2a7b-47e6-bc91-f94d026795c9)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/7ee3082f-1116-4eea-87f9-e060382829e2)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/be1aef96-64a1-4c53-9b62-a928f1ca1614)


![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/f9cd19b5-df6f-412d-9f8e-fd0ebd40c0fc)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/ee83d8b5-6227-4830-b6df-f6000bf348b3)

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/dab8d831-287d-4414-8a64-92ccf29d414d)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/805080f3-fe3d-42a7-8018-f892c4b1d58b)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/59e315e4-583e-4dcc-ad03-e3763fc7a63f)



## Terraform Commands

#### terraform init
- Initializes Terraform in the current directory, downloading necessary plugins and modules.

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/6d60495d-0893-4e3d-bddb-2b9a80e26a2c)


#### terraform plan
- Generates an execution plan, showing proposed changes to infrastructure.

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/e22d6d13-dcb5-4a46-9779-3052232b014f)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/0fb2fbf6-fc4f-436b-83fb-f2075a7e5c8f)



#### terraform validate
- Checks the Terraform configuration for syntax errors and other issues.

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/9cc90f8e-5baf-45e0-bdcb-c91703261793)


#### terraform apply
- Applies planned changes to infrastructure.

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/511c46e7-d539-43c4-80d4-5d7879d46ebd)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/fcb04c4e-0fff-4422-b38e-8bf57dbc6271)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/c00bb7f4-2c0b-4bb1-a6d9-da2484afd866)


#### terraform destroy
- Destroys resources defined in the Terraform configuration.

![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/b3a6b166-fa39-4ad1-ae9e-5c21a71f517d)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/9fbf5198-9b26-49f3-be61-d58747e407bd)
![image](https://github.com/Darshik-12/Terraform-Project/assets/113631093/6dd9c848-97ef-4aa8-80fb-2b68f047cd1b)


