resource "aws_vpc" "dev" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "dev-vpc"
    }
  
}
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags ={
         Name = "dev-sub-1"

    }
  
}
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.dev.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    tags ={
         Name = "dev-sub-2"
         
    }
  
}
resource "aws_internet_gateway" "dev" {
    vpc_id = aws_vpc.dev.id
    tags = {
        Name = "dev-ig"

    }         
  
}
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "dev" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "dev-nat"
  }
}
  
resource "aws_route_table" "dev" {
    vpc_id = aws_vpc.dev.id
    route {
        cidr_block = "0.0.0.0/0"  
        gateway_id = aws_internet_gateway.dev.id
          }
  
}
resource "aws_route_table" "dev_prvt" {
    vpc_id = aws_vpc.dev.id
    route {
        cidr_block = "0.0.0.0/0"  
        nat_gateway_id = aws_nat_gateway.dev.id
          }
}

resource "aws_route_table_association" "dev" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.dev.id
  
}
resource "aws_route_table_association" "dev_prvt" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.dev_prvt.id
}

resource "aws_security_group" "dev" {
    name = "dev-sg"
    description = "allow"
    vpc_id = aws_vpc.dev.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
}
resource "aws_instance" "hani" {
    ami = "ami-02dfbd4ff395f2a1b"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [ aws_security_group.dev.id]
    tags = {
        Name = "prod-instance"
    }
}