K8 Cluster Provisioing on AWS


	This terraform script deploy and initialize a basic Kubernetes cluster on AWS.
Script will,
	1. create a vpc on specified aws region
	2. create internet gateway, subnet and associated routing tables for creating cluster
	3. create the K8 cluster

For customizing the provisioning use the terraform.tfvars file.
	
Parameters

region = "aws region for provisioning K8 cluster"
availability_zone = "availability zone for provisioning cluster"
k8_vpc_cidr_block = "vpc CIDR block"
k8_subnet_cidr_block = "K8 subnet cidr block"
instance_type = "K8 master and node instance type"
ami = "ami to use for creating node"
key = "ssh key for accessing ec2 instances"
k8_nodes = "number of K8 slave nodes"
k8_token = "k8 token for joining nodes to cluster"	



How to run

clone project
cd project
export AWS access key and AWS secret key
terraform init
terraform plan



Improvements
	
1. Fine tune Security groups for more controlled access
2. Control the subnet placing of nodes


Limitations

After provisioning the cluster, bellow command needs to run on the master as user 'ubuntu'
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
