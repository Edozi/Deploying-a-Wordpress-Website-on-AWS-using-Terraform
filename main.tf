# Creating the VPC
resource "aws_vpc" "Edozie_VPC" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "Edozie_VPC"
  }
}

# Creating the Internet Gateway
resource "aws_internet_gateway" "Edozie_Internet_Gateway" {
  vpc_id = aws_vpc.Edozie_VPC.id

  tags = {
    Name = "Edozie_Internet_Gateway"
  }
}

# Creating the Elastic IP
resource "aws_eip" "Edozie_Elastic_IP" {
  domain   = "vpc" 
  depends_on = [aws_internet_gateway.Edozie_Internet_Gateway]

}

# Creating the NAT Gateway
resource "aws_nat_gateway" "Edozie_NAT_Gateway" {
  allocation_id = aws_eip.Edozie_Elastic_IP.id
  subnet_id     = aws_subnet.Edozie_Public_Subnet1.id

  tags = {
    Name = "Edozie_NAT_Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Edozie_Internet_Gateway, aws_eip.Edozie_Elastic_IP]
}

# Creating the Subnets
## Creating the first Public Subnet
resource "aws_subnet" "Edozie_Public_Subnet1" {
  vpc_id     = aws_vpc.Edozie_VPC.id
  cidr_block = var.subnet_cidr_block1
  availability_zone = var.availability_zone1

  tags = {
    Name = "Edozie_Public_Subnet1"
  }
}

## Creating the second Public Subnet
resource "aws_subnet" "Edozie_Public_Subnet2" {
  vpc_id     = aws_vpc.Edozie_VPC.id
  cidr_block = var.subnet_cidr_block2
  availability_zone = var.availability_zone2

  tags = {
    Name = "Edozie_Public_Subnet2"
  }
}

locals {
  public_subnet_ids = [
    aws_subnet.Edozie_Public_Subnet1.id,
    aws_subnet.Edozie_Private_Subnet2.id
  ]
}

## Creating the first Private Subnet
resource "aws_subnet" "Edozie_Private_Subnet1" {
  vpc_id     = aws_vpc.Edozie_VPC.id
  cidr_block = var.subnet_cidr_block3
  availability_zone = var.availability_zone1

  tags = {
    Name = "Edozie_Private_Subnet1"
  }
}

## Creating the second Private Subnet
resource "aws_subnet" "Edozie_Private_Subnet2" {
  vpc_id     = aws_vpc.Edozie_VPC.id
  cidr_block = var.subnet_cidr_block4
  availability_zone = var.availability_zone2

  tags = {
    Name = "Edozie_Private_Subnet2"
  }
}

# Creating the Route Tables
## Creating the first Public Route Table
resource "aws_route_table" "Edozie_Public_Route_Table" {
  vpc_id = aws_vpc.Edozie_VPC.id

  route {
    cidr_block = var.all
    gateway_id = aws_internet_gateway.Edozie_Internet_Gateway.id
  }

  tags = {
    Name = "Edozie_Public_Route_Table1"
  }
}

## Creating the Private Route Table
resource "aws_route_table" "Edozie_Private_Route_Table" {
  vpc_id = aws_vpc.Edozie_VPC.id

  route {
    cidr_block = var.all
    nat_gateway_id = aws_nat_gateway.Edozie_NAT_Gateway.id
  }

  tags = {
    Name = "Edozie_Private_Route_Table"
  }
}

# Creating the route table association
## Creating the first Public Route Table Association
resource "aws_route_table_association" "Edozie_Public_Route_Table_Association1" {
  subnet_id      = aws_subnet.Edozie_Public_Subnet1.id
  route_table_id = aws_route_table.Edozie_Public_Route_Table.id
}

## Creating the second Public Route Table Association
resource "aws_route_table_association" "Edozie_Public_Route_Table_Association2" {
  subnet_id      = aws_subnet.Edozie_Public_Subnet2.id
  route_table_id = aws_route_table.Edozie_Public_Route_Table.id
}

## Creating the first Private Route Table Association
resource "aws_route_table_association" "Edozie_Private_Route_Table_Association1" {
  subnet_id      = aws_subnet.Edozie_Private_Subnet1.id
  route_table_id = aws_route_table.Edozie_Private_Route_Table.id
}

## Creating the second Private Route Table Association
resource "aws_route_table_association" "Edozie_Private_Route_Table_Association2" {
  subnet_id      = aws_subnet.Edozie_Private_Subnet2.id
  route_table_id = aws_route_table.Edozie_Private_Route_Table.id
}

# Creating the Security Groups
## Creating the Security Group for the Wordpress Server
resource "aws_security_group" "Edozie_Wordpress_Security_Group" {
  name        = "Edozie_Wordpress_Security_Group"
  description = "Allow TLS inbound traffic and all outbound traffic for the wordpress website"
  vpc_id      = aws_vpc.Edozie_VPC.id

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Edozie_Wordpress_Security_Group"
  }
}

# Allowing HTTPS port for Wordpress Server
resource "aws_vpc_security_group_ingress_rule" "allow_https_wordpress_server" {
  security_group_id = aws_security_group.Edozie_Wordpress_Security_Group.id
  cidr_ipv4         = var.all
  from_port         = var.https
  ip_protocol       = "tcp"
  to_port           = var.https
}

# Allowing HTTP
resource "aws_vpc_security_group_ingress_rule" "allow_http_wordpress_server" {
  security_group_id = aws_security_group.Edozie_Wordpress_Security_Group.id
  cidr_ipv4         = var.all
  from_port         = var.http
  ip_protocol       = "tcp"
  to_port           = var.http
}

# Allowing SSH
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_wordpress_server" {
  security_group_id = aws_security_group.Edozie_Wordpress_Security_Group.id
  cidr_ipv4         = var.all
  from_port         = var.ssh
  ip_protocol       = "tcp"
  to_port           = var.ssh
}

## Creating the Security Group for the Elastic Load Balancer
resource "aws_security_group" "Edozie_ALB_Security_Group" {
  name        = "Edozie_ALB_Security_Group"
  description = "Allow TLS inbound traffic and all outbound traffic for the Application Load Balancer"
  vpc_id      = aws_vpc.Edozie_VPC.id

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Edozie_ELB_Security_Group"
  }
}

# Allowing HTTPS port for the Elastic Load Balancer
resource "aws_vpc_security_group_ingress_rule" "allow_https_alb" {
  security_group_id = aws_security_group.Edozie_ALB_Security_Group.id
  cidr_ipv4         = var.all
  from_port         = var.https
  ip_protocol       = "tcp"
  to_port           = var.https
}

# Allowing HTTP
resource "aws_vpc_security_group_ingress_rule" "allow_http_elb" {
  security_group_id = aws_security_group.Edozie_ALB_Security_Group.id
  cidr_ipv4         = var.all
  from_port         = var.http
  ip_protocol       = "tcp"
  to_port           = var.http
}


# Creating the Load Balancer
resource "aws_lb" "Edozie_Application_Load_Balancer" {
  name               = "Edozie-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Edozie_ALB_Security_Group.id]
  subnets = local.public_subnet_ids
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# Creating the Application Load Balancer Target Group
resource "aws_lb_target_group" "Edozie_ALB_Target_Group" {
  name     = "Edozie-ALB-Target-Group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Edozie_VPC.id
}

# Creating the Application Load Balancer Listener
resource "aws_lb_listener" "Edozie_LB_Listener" {
  load_balancer_arn = aws_lb.Edozie_Application_Load_Balancer.arn
  port              = var.http
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Edozie_ALB_Target_Group.arn
  }
}
# Creating the Launch Configuration
resource "aws_launch_configuration" "Edozie_Launch_Configuration" {
  name          = "Edozie_Launch_Configuration"
  image_id      = var.instance_image_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.Edozie_Wordpress_Security_Group.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.Edozie_Keypair.key_name
}

# Creating the Auto-Scaling Group
resource "aws_placement_group" "Edozie_Placement_Group" {
  name     = "Edozie_Placement_Group"
  strategy = "spread"
}

resource "aws_autoscaling_group" "Edozie_AutoScaling_Group" {
  name                      = "Edozie_AutoScaling_Group"
  max_size                  = 5
  min_size                  = 3
  health_check_grace_period = 600
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.Edozie_Placement_Group.id
  launch_configuration      = aws_launch_configuration.Edozie_Launch_Configuration.name
  vpc_zone_identifier       = [aws_subnet.Edozie_Public_Subnet1.id, aws_subnet.Edozie_Public_Subnet2.id]

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "Edozie_AutoScaling_Attachment" {
  autoscaling_group_name = aws_autoscaling_group.Edozie_AutoScaling_Group.id
  lb_target_group_arn    = aws_lb_target_group.Edozie_ALB_Target_Group.arn
}

# Creating the Keypair
resource "aws_key_pair" "Edozie_Keypair" {
  key_name   = "Edozie-key"
  public_key = file("Edozie.pub")
}