data "archive_file" "start_stop" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas"
  output_path = "${path.module}/start_stop.zip"
}
