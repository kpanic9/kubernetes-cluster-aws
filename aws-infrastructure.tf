provider "aws" {
	region = "${var.region}"
}

resource "aws_vpc" "k8_vpc" {
	cidr_block       = "${var.k8_vpc_cidr_block}"

	tags {
		Name = "K8-VPC"
	}
}

# subnets
resource "aws_subnet" "k8_public_subnet" {
	vpc_id     = "${aws_vpc.k8_vpc.id}"
	availability_zone  = "${var.availability_zone}"
	cidr_block = "${var.k8_subnet_cidr_block}"
	map_public_ip_on_launch = true
	tags {
		Name = "K8-public-subnet"
	}
}

# internet gateway for public subnet
resource "aws_internet_gateway" "k8-igw" {
	vpc_id = "${aws_vpc.k8_vpc.id}"

	tags {
		Name = "K8-IGW"
	}
}

# public subnet routing table and routes
resource "aws_route_table" "k8_public_subnet" {
	vpc_id = "${aws_vpc.k8_vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.k8-igw.id}"
	}
  
	tags {
		Name = "K8-public-subnet-routing-table"
	}
}

resource "aws_route_table_association" "k8_public_subnet" {
	subnet_id      = "${aws_subnet.k8_public_subnet.id}"
	route_table_id = "${aws_route_table.k8_public_subnet.id}"
}

# security groups
resource "aws_security_group" "k8_master" {
	name = "k8_master_sg"
	description = "K8 master node sg"
	vpc_id = "${aws_vpc.k8_vpc.id}"
	#self = true
	
	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "k8_node" {
	name = "k8_node_sg"
	description = "K8 node sg"
	vpc_id = "${aws_vpc.k8_vpc.id}"
	
	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}	
}

# K8 master node
data "template_file" "k8_master" {
	template = "${file("./k8-master.sh.tpl")}"
	
	vars {
		KUBEADM_TOKEN = "${var.k8_token}"
	}
}

resource "aws_instance" "k8_master" {
	ami = "${var.ami}"
	instance_type = "${var.instance_type}"
	key_name = "${var.key}"
	subnet_id = "${aws_subnet.k8_public_subnet.id}"
	vpc_security_group_ids = ["${aws_security_group.k8_master.id}"]
	associate_public_ip_address = true
	
	user_data = "${data.template_file.k8_master.rendered}"
	
	tags = {
		Name = "K8-Master"
	}
}

# k8 nodes
data "template_file" "k8_node" {
	template = "${file("./k8-node.sh.tpl")}"
	
	vars {
		KUBEADM_TOKEN = "${var.k8_token}"
		MASTER_IP = "${aws_instance.k8_master.public_ip}"
	}
}

resource "aws_instance" "k8_node" {
	ami = "${var.ami}"
	instance_type = "${var.instance_type}"
	key_name = "${var.key}"
	subnet_id = "${aws_subnet.k8_public_subnet.id}"
	vpc_security_group_ids = ["${aws_security_group.k8_node.id}"]
	associate_public_ip_address = true
	count = "${var.k8_nodes}"
	
	user_data = "${data.template_file.k8_node.rendered}"

	depends_on = ["aws_instance.k8_master"]
	
	tags = {
		Name = "K8-Node-${count.index}"
	}
}
