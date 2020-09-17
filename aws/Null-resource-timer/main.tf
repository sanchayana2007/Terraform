#used for testing purpose , 

resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]
  create_duration = "30s"
}

# This resource will create (at least) 30 seconds after null_resource.previous
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_30_seconds]
}
