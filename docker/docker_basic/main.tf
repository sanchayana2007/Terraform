# Create a container

resource "docker_image" "docker_nginx" {


  name = "docker.io/nginx"

}
resource "docker_container" "docker_nginx" {
  name ="test"
  image = "${docker_image.docker_nginx.name}"
  ports{
	internal="80"
	external="1000"


	}

}
