resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = var.cloudwatch_dashboard_name
  dashboard_body = jsonencode({
    "widgets" = [
        {
          type: "metric",
          properties: {
            "metrics": [
              for service_name in var.ecs_service_names : [
                "AWS/ECS",
                "CPUUtilization",
                "ServiceName",
                service_name,
                "ClusterName",
                var.cluster_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "ecs_services_cpu_utilization",
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for service_name in var.ecs_service_names : [
                "AWS/ECS",
                "MemoryUtilization",
                "ServiceName",
                service_name,
                "ClusterName",
                var.cluster_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "ecs_services_memory_utilization"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for load_balancer_identifier in var.load_balancer_identifiers : [
                "AWS/ApplicationELB",
                "RequestCount",
                "LoadBalancer",
                load_balancer_identifier
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "stat": "Sum"
            "title": "elb_request_count"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for load_balancer_identifier in var.load_balancer_identifiers : [
                "AWS/ApplicationELB",
                "HTTPCode_ELB_4XX_Count",
                "LoadBalancer",
                load_balancer_identifier
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "stat": "Sum"
            "title": "elb_4xx_count"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for load_balancer_identifier in var.load_balancer_identifiers : [
                "AWS/ApplicationELB",
                "HTTPCode_Target_4XX_Count",
                "LoadBalancer",
                load_balancer_identifier
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "stat": "Sum"
            "title": "elb_target_4xx_count"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for load_balancer_identifier in var.load_balancer_identifiers : [
                "AWS/ApplicationELB",
                "HTTPCode_ELB_5XX_Count",
                "LoadBalancer",
                load_balancer_identifier
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "stat": "Sum"
            "title": "elb_5xx_count"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for load_balancer_identifier in var.load_balancer_identifiers : [
                "AWS/ApplicationELB",
                "HTTPCode_Target_5XX_Count",
                "LoadBalancer",
                load_balancer_identifier
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "stat": "Sum"
            "title": "elb_target_5xx_count"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for load_balancer_identifier in var.load_balancer_identifiers : [
                "AWS/ApplicationELB",
                "TargetResponseTime",
                "LoadBalancer",
                load_balancer_identifier
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "elb_target_response_time"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "CPUUtilization",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_cpu_utlization"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "DatabaseConnections",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_database_connections"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "EBSByteBalance%",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_ebs_byte_balance"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "EBSIOBalance%",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_ebs_io_balance"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "FreeableMemory",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_freeable_memory"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "FreeStorageSpace",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_free_storage_space"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "ReadIOPS",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_read_iops"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "WriteIOPS",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_write_iops"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "ReadLatency",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_read_latency"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "WriteLatency",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_write_latency"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "ReadThroughput",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_read_throughput"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for rds_instance_name in var.rds_instance_names : [
                "AWS/RDS",
                "WriteThroughput",
                "DBInstanceIdentifier",
                rds_instance_name
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "rds_write_throughput"
            "view": "timeSeries"
          }
        },
        {
          type: "metric",
          properties: {
            "metrics": [
              for ec2_instance_id in var.ec2_instance_ids : [
                "AWS/EC2",
                "CPUUtilization",
                "InstanceId",
                ec2_instance_id,
              ]
            ],
            "period": 60
            "region": var.region,
            "stacked": false,
            "title": "ec2_instances_cpu_utilization",
            "view": "timeSeries"
        }
      },
      {
        type: "metric",
        properties: {
          "metrics": [
            for ec2_instance_id in var.ec2_instance_ids : [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              ec2_instance_id,
            ]
          ],
          "period": 60
          "region": var.region,
          "stacked": false,
          "title": "ec2_instances_network_in",
          "view": "timeSeries"
        }
      },
      {
        type: "metric",
        properties: {
          "metrics": [
            for ec2_instance_id in var.ec2_instance_ids : [
              "AWS/EC2",
              "NetworkOut",
              "InstanceId",
              ec2_instance_id,
            ]
          ],
          "period": 60
          "region": var.region,
          "stacked": false,
          "title": "ec2_instances_network_out",
          "view": "timeSeries"
        }
      },
      ]
    }
  )
}