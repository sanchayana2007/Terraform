resource "aws_instance" "test" {
count = 5 
ami = "ami-0a54aef4ef3b5f881"
instance_type="t2.micro"

tags= {
Name = "sample-$(count.index)"
}




}


