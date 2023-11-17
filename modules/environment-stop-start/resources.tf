resource "local_file" "resources" {
  content  = jsonencode(var.resources)
  filename = "${path.module}/lambdas/resources.json"
}
