resource "aws_efs_file_system" "db_dump" {
  encrypted = true

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}"
    "TYPE" = "EFS"
  }

  throughput_mode = "elastic"
}

resource "aws_efs_access_point" "db_dump" {
  file_system_id = aws_efs_file_system.db_dump.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "700"
    }
    path = "/pgmigrate"
  }

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}"
  }
}

resource "aws_efs_file_system_policy" "db_dump" {
  file_system_id = aws_efs_file_system.db_dump.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessViaMountTarget",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "elasticfilesystem:AccessedViaMountTarget": "true"
                }
            },
            "Resource" : "${aws_efs_file_system.db_dump.arn}"
        }
    ]
}
EOF
}

resource "aws_efs_mount_target" "db_dump" {
  # Conditional logic to ensure backwards compatibility
  for_each        = length(var.efs_subnet_ids) > 0 ? var.efs_subnet_ids : [var.subnet_id]
  file_system_id  = aws_efs_file_system.db_dump.id
  security_groups = [aws_security_group.db_dump_fs.id]
  subnet_id       = each.value
}

resource "aws_security_group" "db_dump_fs" {
  name        = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:EFS"
  description = "FS for db dump during Postgres migration process"
  vpc_id      = var.vpc_id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:EFS"
  }
}

resource "aws_security_group" "db_dump_fs_clients" {
  name        = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:EFS:CLIENTS"
  description = "Entities permitted to access the EFS filesystem"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGMIGRATOR:${upper(var.migrator_name)}:EFS:CLIENTS"
  }
}

resource "aws_security_group_rule" "db_dump_fs_clients_nfs_out" {
  description              = "Allow NFS outwards from filesystem clients to filesystem"
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_dump_fs_clients.id
  source_security_group_id = aws_security_group.db_dump_fs.id
  to_port                  = 2049
  type                     = "egress"
}

resource "aws_security_group_rule" "db_dump_fs_efs_in" {
  description              = "Allow NFS inwards from filesystem clients to filesystem"
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_dump_fs.id
  source_security_group_id = aws_security_group.db_dump_fs_clients.id
  to_port                  = 2049
  type                     = "ingress"
}
