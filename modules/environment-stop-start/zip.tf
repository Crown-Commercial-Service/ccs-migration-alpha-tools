data "archive_file" "start_stop" {
  type        = "zip"
  source_file = "${path.module}/lambdas/start_stop.py"
  output_path = "${path.module}/lambdas/start_stop.zip"
}
