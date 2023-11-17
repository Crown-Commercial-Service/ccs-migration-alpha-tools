data "archive_file" "start_stop" {
  depends_on = [
    local_file.resources
  ]
  type        = "zip"
  source_file = "${path.module}/lambdas/start_stop.py"
  output_path = "${path.module}/lambdas/start_stop.zip"
}
