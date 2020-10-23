# availability zone for provisioning cluster
variable "availability_zone" {
  type    = string
  default = "ca-central-1a"
}

# vpc CIDR block
variable "vpc_cidr" {
  type    = string
  default = "10.16.0.0/16"
}

# K8 subnet cidr block
variable "public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.16.31.0/24"]
}

# K8 master and node instance type
variable "instance_type" {
  type    = string
  default = "t2.medium"
}

# ami to use for creating node, should be ubuntu based ami
variable "ami" {
  type    = string
  default = "ami-0427e8367e3770df1"
}

# ssh key for accessing ec2 instances
variable "key" {
  type    = string
  default = "caneda"
}

# number of K8 slave nodes
variable "worker_nodes" {
  type    = string
  default = "2"
}

# k8 token for joining nodes to cluster
# must be changed for security
variable "k8s_token" {
  type    = string
  default = "abcdef.0123456789abcdef"
}
