output "private_subnets" {
  value = ["${aws_subnet.private.*.id}"]
}

output "public_subnets" {
  value = ["${aws_subnet.public.*.id}"]
}

output "vpc_id" {
  value = "${aws_vpc.VPC.id}"
}

output "nat_eips_id" {
  value = ["${aws_eip.ipwan.*.id}"]
}

output "nat_eips_public_ips" {
  value = ["${aws_eip.ipwan.*.public_ip}"]
}

output "natgw_ids" {
  value = ["${aws_nat_gateway.GW.*.id}"]
}

output "igw_id" {
  value = "${aws_internet_gateway.IG.id}"
}