resource "aws_efs_file_system" "db_restore" {
  encrypted = true

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}"
    "TYPE" = "EFS"
  }

  throughput_mode = "elastic"
}

resource "aws_efs_access_point" "db_restore" {
  file_system_id = aws_efs_file_system.db_restore.id

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
    path = "/pgrestore"
  }

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}"
  }
}

resource "aws_efs_file_system_policy" "db_restore" {
  file_system_id = aws_efs_file_system.db_restore.id

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
            "Resource" : "${aws_efs_file_system.db_restore.arn}"
        }
    ]
}
EOF
}

resource "aws_efs_mount_target" "db_restore" {
  for_each        = var.efs_subnet_ids
  file_system_id  = aws_efs_file_system.db_restore.id
  security_groups = [aws_security_group.db_restore_fs.id]
  subnet_id       = each.value
}

resource "aws_security_group" "db_restore_fs" {
  name        = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}:EFS"
  description = "FS for db dump during Postgres restore process"
  vpc_id      = var.vpc_id

  tags = {
    "Name" = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}:EFS"
  }
}

resource "aws_security_group" "db_restore_fs_clients" {
  name        = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}:EFS:CLIENTS"
  description = "Entities permitted to access the EFS filesystem"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.resource_name_prefixes.normal}:PGRESTORE:${upper(var.restore_name)}:EFS:CLIENTS"
  }
}

resource "aws_security_group_rule" "db_restore_fs_clients_nfs_out" {
  description              = "Allow NFS outwards from filesystem clients to filesystem"
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_restore_fs_clients.id
  source_security_group_id = aws_security_group.db_restore_fs.id
  to_port                  = 2049
  type                     = "egress"
}

resource "aws_security_group_rule" "db_restore_fs_efs_in" {
  description              = "Allow NFS inwards from filesystem clients to filesystem"
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_restore_fs.id
  source_security_group_id = aws_security_group.db_restore_fs_clients.id
  to_port                  = 2049
  type                     = "ingress"
}
