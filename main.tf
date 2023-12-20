/**
* Creamos los servidores para Quiter
**/

resource "aws_instance" "quiter_dms" {
  provider = aws.client
  depends_on = [ 
    tls_private_key.primary,
    tls_private_key.cliente,
    aws_key_pair.aws-primary-key
  ]
  ami           = "ami-02358d9f5245918a3"
  instance_type = var.dms-instance-type-user["users_${var.quiter-users}"]
  vpc_security_group_ids       = [
    aws_security_group.quiter_sg.id,
  ]
  disable_api_termination = true

  subnet_id = aws_subnet.private_subnet_1.id
  key_name = aws_key_pair.aws-primary-key.key_name

  root_block_device {
    volume_type = "gp3"
    iops = 16000
    throughput = 250
    volume_size = 50
  }

  ebs_block_device {
    volume_type = "gp3"
    device_name = "/dev/sdb"
    iops = 16000
    throughput = 260
    volume_size = var.dms-storage
  }

  user_data = <<EOF
#!/bin/bash
sudo useradd admin -s /bin/bash
sudo mkdir /home/admin/
sudo mkdir /home/admin/.ssh/
sudo echo "${tls_private_key.cliente.public_key_openssh}" >>  /home/admin/.ssh/authorized_keys
sudo usermod -a -G root admin
sudo usermod -aG wheel admin
sudo echo "admin    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

sudo yum install lvm2 -y
sudo pvcreate /dev/nvme1n1
sudo vgcreate quiter /dev/nvme1n1
sudo lvcreate -n quiter-data -L ${(var.dms-storage)-1}G quiter
sudo mkdir /u2
sudo mkfs -t xfs /dev/quiter/quiter-data
sudo mount /dev/quiter/quiter-data /u2
sudo bash -c 'echo "/dev/quiter/quiter-data /u2  xfs     defaults,nofail   0   0" >> /etc/fstab'
sudo systemctl daemon-reloads
  EOF

  tags = {
    Name = "${var.client}-quiter_dms"
    project = "quiter"
    backup_by = "tc"
  }
}

resource "aws_instance" "quiter_qae" {
  provider = aws.client
  depends_on = [ 
    tls_private_key.primary,
    tls_private_key.cliente,
    aws_key_pair.aws-primary-key
  ]
  ami           = "ami-02358d9f5245918a3"
  instance_type = var.qae-instance-type-user["users_${var.quiter-users}"]
  vpc_security_group_ids       = [
    aws_security_group.quiter_sg.id,
  ]
  disable_api_termination = true

  subnet_id = aws_subnet.private_subnet_1.id
  key_name = aws_key_pair.aws-primary-key.key_name

  root_block_device {
    volume_type = "gp3"
    iops = 5000
    throughput = 200
    volume_size = 50
  }

  ebs_block_device {
    volume_type = "gp3"
    device_name = "/dev/sdb"
    iops = 5000
    throughput = 200
    volume_size = var.qae-storage
  }

  user_data = <<EOF
#!/bin/bash
sudo useradd admin -s /bin/bash
sudo mkdir /home/admin/
sudo mkdir /home/admin/.ssh/
sudo echo "${tls_private_key.cliente.public_key_openssh}" >>  /home/admin/.ssh/authorized_keys
sudo usermod -a -G root admin
sudo usermod -aG wheel admin
sudo echo "admin    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

sudo yum install lvm2 -y
sudo pvcreate /dev/nvme1n1
sudo vgcreate quiter /dev/nvme1n1
sudo lvcreate -n quiter-data -L ${(var.qae-storage)-1}G quiter
sudo mkdir /repositorios
sudo mkfs -t xfs /dev/quiter/quiter-data
sudo mount /dev/quiter/quiter-data /repositorios
sudo bash -c 'echo "/dev/quiter/quiter-data /repositorios  xfs     defaults,nofail   0   0" >> /etc/fstab'
sudo systemctl daemon-reloads
  EOF

  tags = {
    Name = "${var.client}-quiter_qae"
    project = "quiter"
    backup_by = "tc"
  }
}

/**
* CREAMOS EL HOST BASTION PARA SOPORTE TOTALCLOUD
**/

resource "aws_instance" "bastion_host" {
  provider = aws.client
  depends_on = [ 
    tls_private_key.primary,
    tls_private_key.cliente,
    tls_private_key.quiter,
    aws_key_pair.aws-primary-key
  ]
  ami                       = "ami-00874d747dde814fa"
  instance_type             = "t3a.nano"
  vpc_security_group_ids    = [aws_security_group.totalcloud-support.id]
  subnet_id                 = aws_subnet.public_subnet_1.id
  key_name                  = aws_key_pair.aws-primary-key.key_name

  root_block_device {
    volume_type = "gp3"
    iops = 3000
    throughput = 125
    volume_size = 50
  }

  user_data = <<EOF
#!/bin/bash
sudo su
useradd tc-support -s /bin/bash
echo "tc-support:${var.tc_support_password}" | sudo chpasswd
mkdir /home/tc-support/
echo "${tls_private_key.cliente.private_key_pem}" >>  /home/tc-support/admin.pem
chown root:tc-support /home/tc-support/admin.pem
chmod 440 /home/tc-support/admin.pem

usermod -a -G root tc-support
usermod -aG wheel tc-support
echo "tc-support    ALL=(ALL)       ALL" >> /etc/sudoers

useradd quiter-support -s /bin/bash
mkdir /home/quiter-support/
mkdir /home/quiter-support/.ssh/
echo "${tls_private_key.quiter.public_key_openssh}" >>  /home/quiter-support/.ssh/authorized_keys
usermod -a -G tc-support quiter-support
ln -s /home/tc-support/admin.pem /home/quiter-support/
chown -h root:tc-support /home/quiter-support/admin.pem
chmod 440 /home/quiter-support/admin.pem

sudo shutdown
  EOF

  tags = {
    Name = "${var.client}-bastion-host"
    project = "quiter"
  }
}
