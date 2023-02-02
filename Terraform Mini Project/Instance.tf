#Create Security Groups (SG)
#Instance SG
resource "aws_security_group" "SG_EC2" {
  name        = "EC2 Security Group"
  description = "Securty Group for the 3 Instances"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#Load Balancer SG
resource "aws_security_group" "SG_LB" {
  name        = "LB Security Group"
  description = "Securty Group for the load balancer"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key_pair" {
  key_name = "public_key"
  public_key = file(var.pub_key)
}

#Create Instances
resource "aws_instance" "Instance1" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "public_key"
  security_groups = [aws_security_group.SG_EC2.id]
  subnet_id       = aws_subnet.public_subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "Instance1"
    source = "terraform"
  }
}

resource "aws_instance" "Instance2" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "public_key"
  security_groups = [aws_security_group.SG_EC2.id]
  subnet_id       = aws_subnet.public_subnet2.id
  availability_zone = "us-east-1b"
  tags = {
    Name   = "Instance2"
    source = "terraform"
  }
}

resource "aws_instance" "Instance3" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "public_key"
  security_groups = [aws_security_group.SG_EC2.id]
  subnet_id       = aws_subnet.public_subnet3.id
  availability_zone = "us-east-1c"
  tags = {
    Name   = "Instance3"
    source = "terraform"
  }
}

#Save the public IP of the instances in a file
resource "local_file" "Ip_address" {
  filename = "/vagrant/Terraform Mini Project/ansible/host-inventory"
  content  = <<EOT
${aws_instance.Instance1.public_ip}
${aws_instance.Instance2.public_ip}
${aws_instance.Instance3.public_ip}
  EOT
}

#Create Application Load Balancer
resource "aws_lb" "applicationlb" {
  name               = "applicationlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG_LB.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id, aws_subnet.public_subnet3.id]
  enable_deletion_protection = false
  depends_on = [
    aws_instance.Instance1, aws_instance.Instance2, aws_instance.Instance3
  ]
 }

#Create ALB Target Group
resource "aws_lb_target_group" "alb-target-grp" {
  name        = "alb-target-grp"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id

}

#Create a listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.applicationlb.arn
  port              = "80"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-grp.arn
  }
}

#Create the listener rule
resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-grp.arn
  }

  condition {
    path_pattern {
      values = ["/"]
  }
  
  }
}

# Attach TG to the LB
resource "aws_lb_target_group_attachment" "TGattachment1" {
  target_group_arn = aws_lb_target_group.alb-target-grp.arn
  target_id        = aws_instance.Instance1.id
  port             = 80
}
 
resource "aws_lb_target_group_attachment" "TGattachment2" {
  target_group_arn = aws_lb_target_group.alb-target-grp.arn
  target_id        = aws_instance.Instance2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "TGattachment3" {
  target_group_arn = aws_lb_target_group.alb-target-grp.arn
  target_id        = aws_instance.Instance3.id
  port             = 80 
  
  }