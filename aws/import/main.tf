
resource "aws_instance" "test" {
ami = "ami-0a54aef4ef3b5f881"
instance_type="t2.micro"

}

output "address"{
value="${aws_instance.test.public_ip}"
}


