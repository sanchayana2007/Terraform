resource "docker_network" "dev" {
        name = "dev"
}

resource "docker_image" "web" {
  name = "docker.io/jpetazzo/trainingwheels"
}

resource "docker_container" "web" {
        name = "web"
        image = "${docker_image.web.name}"
        ports {
           internal = "5000"
           external = "5000"
   }
   networks_advanced {
                name = "${docker_network.dev.name}"
          }
}

resource "docker_image" "redis" {
  name = "docker.io/redis"
}

resource "docker_container" "redis" {
        name = "redis"
        image = "${docker_image.redis.name}"
   networks_advanced {
                name = "${docker_network.dev.name}"
          }
}


