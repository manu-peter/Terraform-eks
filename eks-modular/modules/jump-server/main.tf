resource "aws_instance" "bastion" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t3.micro"
  key_name      = var.key_name
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  associate_public_ip_address = true

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    apt-get install unzip -y
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
    curl -LO "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    apt-get install -y tree jq git
    echo "Bastion ready!" > /home/ubuntu/setup-done.txt
  EOF
  )

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = { Name = "${var.cluster_name}-bastion" }
}
