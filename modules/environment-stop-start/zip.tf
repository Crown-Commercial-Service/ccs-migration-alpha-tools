data "archive_file" "start_stop" {
  depends_on = [
    local_file.resources
  ]
  type        = "zip"
  source_dir = "${path.module}/lambdas"
  output_path = "${path.module}/start_stop.zip"
}
