resource "aws_route_table" "default" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.internet_gateway}"
  }

  tags = "${map("Name", "${var.cluster_name}")}"
}

# Subnets (one per availability zone)
# Public Subnet for Bastion host
resource "aws_subnet" "public" {
  count             = "${length(var.master_azs)}"
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${var.master_azs[count.index]}"
  cidr_block        = "${var.public_subnet_cidr}"

  #ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.network.ipv6_cidr_block, 8, count.index)}"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = false
  tags                            = "${map("Name", "${var.cluster_name}-public-${count.index}")}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.master_azs)}"
  route_table_id = "${aws_route_table.default.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}
