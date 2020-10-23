# K8s master node
data "template_file" "master" {
  template = file("${path.module}/master.sh.tpl")

  vars = {
    KUBEADM_TOKEN = var.k8s_token
  }
}

resource "aws_instance" "master" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.master.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.master.rendered

  tags = {
    Name = "master"
  }
}

# worker nodes
data "template_file" "worker" {
  template = file("${path.module}/worker.sh.tpl")

  vars = {
    KUBEADM_TOKEN = var.k8s_token
    MASTER_IP     = aws_instance.master.public_ip
  }
}

resource "aws_instance" "worker" {
  count                       = var.worker_nodes
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key
  subnet_id                   = aws_subnet.public[length(var.public_subnets) % (count.index + 1)].id
  vpc_security_group_ids      = [aws_security_group.worker.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.worker.rendered
  depends_on                  = [aws_instance.master]

  tags = {
    Name = "worker-node-${count.index}"
  }
}
