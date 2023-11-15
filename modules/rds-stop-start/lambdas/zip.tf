data "archive_file" "start_stop_rds_function" {
  type        = "zip"
  source_file = "${path.module}/start_stop_rds.py"
  output_path = "${path.module}/start_stop_rds.zip"
}
