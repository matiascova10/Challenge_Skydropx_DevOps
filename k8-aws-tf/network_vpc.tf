#Asigno Internet Gateway a la VPC
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id 
}

#Asigno una Elastic IP
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.prod-igw]
}

#Creo el Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.prod-igw]
}

#Creo la tabla de ruteo para las subnets privadas
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.prod-vpc.id
}

#Creo la tabla de ruteo para las subnets publicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.prod-vpc.id
}

#Creo una ruta por default para la salida a internet en la RT publica
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prod-igw.id
}

#Creo una ruta por default para la salida a internet en la RT privada
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

#Asocio las subnets publicas en la RT publica
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

#Asocio las subnets publicas en la RT privada
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.priv-subnet-1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.priv-subnet-2.id
  route_table_id = aws_route_table.private.id
}