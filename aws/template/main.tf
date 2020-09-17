
resource "aws_instance" "test" {
ami = "ami-0a54aef4ef3b5f881"
instance_type="${trimspace(data.template_file.user_data.rendered)}"
tags= {
Name="test1"
}

}
variable "env"{
	default = "dev"
}

data "template_file" "user_data" {
template= "${file("${path.module}/template_${var.env}.tpl")}"

}






