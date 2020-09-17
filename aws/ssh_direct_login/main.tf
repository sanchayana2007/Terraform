
resource "aws_instance" "test" {
ami = "ami-0a54aef4ef3b5f881"
instance_type="t2.micro"

}

#Autologn to aws 
resource "aws_key_pair" "sample"{

key_name="sample"
public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAsZQtA9jmPxrTI04rVE72J+pja4IOVZGG1/FKFJexRsf9eP01Hb8PTF0R83tZzF6jIGjVPyL/VVAU4Ji4F1mRrxTLHkHjdhAbKaFUVB7m7GpKGqJVwEzYtuY17LnEzMbAy7gF6XRl0W9AeH5Q8BHiLJziX7jubSC7j29ZALkgiVYrpQmSeIWfHYwkuSVc7JULWZrUHsKTsDZkieomasgzzuStkY71UmKD7vttu+G/XWQKcopkXga8+1mG48t5hIqlRJGsdt6M7eg7F+GFHSDC5iSq7TqwwWyMdliMpzmWxdbkJxFbf/x6bmJPYGP/hC9jyi6AnUIx1d3iCfHFLNHB san@san-Dell-System-Inspiron-N411Z"

}

#run a command on the remote machine just created 
provisioner "remote-exec" 
command = "sudo echo Welcome > /etc/motd"
}


output "address"{
value="${aws_instance.test.public_ip}"
}

resource "aws_instance" "first_instance" {
  ami = var.ami
  key_name = "mano-key"
  instance_type = var.instance_type
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /etc/motd",
      "sudo echo ${var.welcome_message} > /etc/motd",
      "sudo chmod 644 /etc/motd",
    ]
    connection {
      host = "${self.public_dns}"
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}
