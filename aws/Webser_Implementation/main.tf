resource "aws_key_pair" "sample" {
  key_name   = "sample"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0a54aef4ef3b5f881"
  instance_type = "t2.micro"
  key_name = "sample"

  tags = {
    Name = "web"
  }

  vpc_security_group_ids = ["${aws_security_group.web_server.id}"]

  provisioner "file" {
    source = "web.sh"
    destination = "/tmp/web.sh"
    connection {
      host = "${self.public_dns}"
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/web.sh",
      "/tmp/web.sh",
    ]
    connection {
      host = "${self.public_dns}"
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}

resource "aws_security_group" "web_server" {
  name = "web"
}

resource "aws_security_group_rule" "allow_all_inbound" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "TCP"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "TCP"
  security_group_id = "${aws_security_group.web_server.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_https_inbound" {
  type              = "ingress"
   security_group_id = "${aws_security_group.web_server.id}"
 from_port         = "443"
  to_port           = "443"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

