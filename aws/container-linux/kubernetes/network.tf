# data "aws_availability_zones" "all" {}
# # Network VPC, gateway, and routes
# resource "aws_vpc" "network" {
#   cidr_block                       = "${var.host_cidr}"
#   assign_generated_ipv6_cidr_block = true
#   enable_dns_support               = true
#   enable_dns_hostnames             = true
#   tags = "${map("Name", "${var.cluster_name}")}"
# }
# resource "aws_route_table" "private_routes" {
#   count  = "${length(var.worker_azs)}"
#   vpc_id = "${var.vpc_id}"
#   tags = "${map("Name", "${var.cluster_name}")}"
# }
# resource "aws_internet_gateway" "gateway" {
#   vpc_id = "${var.vpc_id}"
#   tags = "${map("Name", "${var.cluster_name}")}"
# }
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
  cidr_block        = "${cidrsubnet(var.host_cidr, 4, count.index)}"

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

# resource "aws_subnet" "master" {
#   count = "${length(data.aws_availability_zones.all.names)}"
#   vpc_id            = "${var.vpc_id}"
#   availability_zone = "${data.aws_availability_zones.all.names[count.index]}"
#   cidr_block = "${cidrsubnet(var.host_cidr, 4, count.index)}"
#   #ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.network.ipv6_cidr_block, 8, count.index)}"
#   map_public_ip_on_launch         = false
#   assign_ipv6_address_on_creation = false
#   tags = "${map("Name", "${var.cluster_name}-master-${count.index}")}"
# }
# resource "aws_route_table_association" "master" {
#   count = "${length(data.aws_availability_zones.all.names)}"
#   route_table_id = "${aws_route_table.default.id}"
#   subnet_id      = "${var.master_subnets[0]}"
# }
# resource "aws_subnet" "workers" {
#   count = "${length(data.aws_availability_zones.all.names)}"
#   vpc_id            = "${var.vpc_id}"
#   availability_zone = "${data.aws_availability_zones.all.names[count.index]}"
#   cidr_block = "${cidrsubnet(var.host_cidr, 4, count.index)}"
#   #ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.network.ipv6_cidr_block, 8, count.index)}"
#   map_public_ip_on_launch         = false
#   assign_ipv6_address_on_creation = false
#   tags = "${map("Name", "${var.cluster_name}-workers-${count.index}")}"
# }
# resource "aws_route_table_association" "workers" {
#   count = "${length(data.aws_availability_zones.all.names)}"
#   route_table_id = "${aws_route_table.default.id}"
#   subnet_id      = "${var.worker_subnets[0]}"
# }

