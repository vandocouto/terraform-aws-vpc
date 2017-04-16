
// Create VPC

resource "aws_vpc" "mod" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags                 = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

// # Public Subnet Configure

resource "aws_internet_gateway" "mod" {
  vpc_id              = "${aws_vpc.mod.id}"
  tags                = "${merge(var.tags, map("Name", format("%s-igw", var.name)))}"
}

resource "aws_route_table" "public" {
  vpc_id              = "${aws_vpc.mod.id}"
  propagating_vgws    = ["${var.public_propagating_vgws}"]
  tags                = "${merge(var.tags, map("Name", format("%s-rt-public", var.name)))}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod.id}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.mod.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  count                   = "${length(var.public_subnets)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  tags                    = "${merge(var.tags, map("Name", format("%s-subnet-public-%s", var.name, element(var.azs, count.index))))}"

}

resource "aws_route_table_association" "public" {
  count                   = "${length(var.public_subnets)}"
  subnet_id               = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id          = "${aws_route_table.public.id}"
}

// # Private Subnet Configure

resource "aws_eip" "ipwan" {
  	depends_on            = ["aws_internet_gateway.mod"]
  	vpc                   = true
}

resource "aws_nat_gateway" "GW" {
  allocation_id     = "${element(aws_eip.ipwan.*.id, count.index)}"
  subnet_id         = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on        = ["aws_internet_gateway.mod"]
}

resource "aws_route_table" "private" {
  vpc_id           = "${aws_vpc.mod.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]
  count            = "${length(var.private_subnets)}"
  tags             = "${merge(var.tags, map("Name", format("%s-rt-private-%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.mod.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.private_subnets)}"
  tags              = "${merge(var.tags, map("Name", format("%s-subnet-private-%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.GW.*.id, count.index)}"
  count                  = "${length(var.private_subnets)}"
  depends_on            = ["aws_nat_gateway.GW"]
}

