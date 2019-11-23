variable "ssh_key_name" {default = "amiuser"}
variable "aws_region_name" { default = "us-east-2" }


provider "aws" {
 
  access_key = "enter your access key"
  secret_key = "enter your secret key"
  region = "${var.aws_region_name}"
}

data "external" "myipaddr" {
  
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
  
}
#https://cloud-images.ubuntu.com/locator/ec2/


# Master Node

resource "aws_instance" "kbs-master" {
ami = "ami-0d5d9d301c853a04a"
instance_type = "t2.micro"
count         = "1"
 vpc_security_group_ids = ["${aws_security_group.cluster_sg.id}"]

  key_name = "${var.ssh_key_name}"

  tags {
    Name   = "kbs-master"
    App    = "kbscluster"
    k8srole = "master"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"


  #private_key = "${file("amiuser.pem")}"   
 private_key = "${file("${var.ssh_key_name}.pem")}"   
        timeout = "2m"
        agent = false
  }
  

 provisioner "file" {
    source      = "scripts"
    destination = "/home/ubuntu"
  }
   provisioner "file" {
    source      = "yamls"
    destination = "/home/ubuntu"
  }
  
    provisioner "remote-exec" {
    inline = [
      "chmod +x ~/scripts/kb_master.sh",
      "~/scripts/kb_master.sh",
      
    ]
  }

}

#Worker Nodes

resource "aws_instance" "kbs-worker" {
ami = "ami-0d5d9d301c853a04a"
instance_type = "t2.micro"
count         = "2"
vpc_security_group_ids = ["${aws_security_group.cluster_sg.id}"]
key_name = "${var.ssh_key_name}"
  tags {
    Name   = "kbs-worker"
    App    = "kbscluster"
    k8srole = "worker"
  }

   connection {
    type        = "ssh"
    user        = "ubuntu"


 private_key = "${file("${var.ssh_key_name}.pem")}" 
        timeout = "2m"
        agent = false
  }
  provisioner "file" {
    source      = "scripts"
    destination = "/home/ubuntu"
  }
    
    provisioner "remote-exec" {
    inline = [
           "chmod +x ~/scripts/kb_worker.sh",
           "~/scripts/kb_worker.sh ${aws_instance.kbs-master.private_ip}",
    ]
  
  }
}

resource "aws_security_group" "cluster_sg" {

}

resource "aws_security_group_rule" "allow_all_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "all"
  cidr_blocks     = ["0.0.0.0/0"]
  description     = "Outbound access to ANY"

  security_group_id = "${aws_security_group.cluster_sg.id}"
}


resource "aws_security_group_rule" "allow_all_myip" {
  type            = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "all"
  cidr_blocks     = ["${data.external.myipaddr.result["ip"]}/32"]
  description     = "Management Ports for Kbs Cluster"

  security_group_id = "${aws_security_group.cluster_sg.id}"
}

resource "aws_security_group_rule" "allow_SG_any" {
  type            = "ingress"
  from_port       = 0
  to_port         = 0
  protocol        = "all"
  self            = true
  description     = "Any from SG for Kbs Cluster"

  security_group_id = "${aws_security_group.cluster_sg.id}"
}

output "master_ip" {
  value = "${aws_instance.kbs-master.public_ip}"
}
output "master_local_ip" {
  value = "${aws_instance.kbs-master.private_ip}"
}
output "worker_ips" {
  value = "${aws_instance.kbs-worker.*.public_ip}"
}
output "worker_local_ips" {
  value = "${aws_instance.kbs-worker.*.private_ip}"
}
