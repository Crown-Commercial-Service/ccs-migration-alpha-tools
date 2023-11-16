data "archive_file" "start_stop_rds_function" {
  type        = "zip"
  source_file = "${path.module}/lambdas/start_stop_rds.py"
  output_path = "${path.module}/lambdas/start_stop_rds.zip"
}
