
resource "aws_instance" "test" {
ami = "ami-0a54aef4ef3b5f881"
count= var.Y_N == true ? 1:0
instance_type="t2.micro"
tags= {

Name="test1"

}

}


