data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
key_name = "assignment-key-pair"
  tags = {
    Name = "master"
  }
  provisioner "file" {
    source      = "./master.sh"
    destination = "/home/ubuntu/master.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./assignment-key-pair.pem")}"
      host        = "${self.public_dns}"
    }
  }
  provisioner "file" {
    source      = "./common.sh"
    destination = "/home/ubuntu/common.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./assignment-key-pair.pem")}"
      host        = "${self.public_dns}"
    }
  }
  
  }
resource "aws_instance" "worker1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "assignment-key-pair"
  tags = {
    Name = "worker-1"
  }
  provisioner "file" {
    source      = "./worker.sh"
    destination = "/home/ubuntu/worker.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./assignment-key-pair.pem")}"
      host        = "${self.public_dns}"
    }
  }
  provisioner "file" {
    source      = "./common.sh"
    destination = "/home/ubuntu/common.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./assignment-key-pair.pem")}"
      host        = "${self.public_dns}"
    }
  }
  
}

resource "aws_instance" "worker2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "assignment-key-pair"
  tags = {
    Name = "worker-2"
  }
  provisioner "file" {
    source      = "./worker.sh"
    destination = "/home/ubuntu/worker.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./assignment-key-pair.pem")}"
      host        = "${self.public_dns}"
    }
    }
    provisioner "file" {
    source      = "./common.sh"
    destination = "/home/ubuntu/common.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./assignment-key-pair.pem")}"
      host        = "${self.public_dns}"
    }
  }
  
}


#copy the public ip of all somewhere it is required in future.

output "instance_public_ip_master" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.master.public_ip
}
output "instance_public_ip_worker1" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.worker1.public_ip
}
output "instance_public_ip_worker2" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.worker2.public_ip
}

