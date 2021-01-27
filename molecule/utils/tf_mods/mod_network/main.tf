provider "aws" {
  region     = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.244.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.244.1.0/24"

  availability_zone = "eu-west-1a"
}

resource "aws_internet_gateway" "as_igw" {
  vpc_id  = "${aws_vpc.main.id}"
}

resource "aws_route_table" "as_route" {
  vpc_id  = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.as_igw.id
  }
}

resource "aws_route_table_association" "as_rta_subn1" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.as_route.id
}
