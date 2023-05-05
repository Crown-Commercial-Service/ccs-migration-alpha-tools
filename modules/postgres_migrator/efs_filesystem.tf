resource "aws_efs_file_system" "filesystem" {
  encrypted = true

  tags = {
    "Name" = "${var.naming_prefix}:PGMIGRATE"
    "TYPE" = "EFS"
  }
}

resource "aws_efs_access_point" "access" {
  file_system_id = aws_efs_file_system.filesystem.id

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
    "Name" = "${var.naming_prefix}:PGMIGRATE"
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.filesystem.id

  policy = <<POLICY
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
            "Resource" : "${aws_efs_file_system.filesystem.arn}"
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "target" {
  for_each = var.subnets

  file_system_id  = aws_efs_file_system.filesystem.id
  security_groups = [aws_security_group.filesystem.id]
  subnet_id       = each.value
}

resource "aws_security_group" "filesystem" {
  name        = "${var.naming_prefix}:PGMIGRATE:EFS"
  description = "EFS for PG Migrate process"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.naming_prefix}:PGMIGRATE:EFS"
  }
}

resource "aws_security_group" "filesystem_clients" {
  name        = "${var.naming_prefix}:PGMIGRATE:EFS:CLIENTS"
  description = "Entities permitted to access the ${var.naming_prefix}:PGMIGRATE:EFS filesystem"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.naming_prefix}:PGMIGRATE:EFS:CLIENTS"
  }
}

resource "aws_security_group_rule" "filesystem_efs_in" {
  security_group_id = aws_security_group.filesystem.id
  description       = "Allow ${local.nfs_port} inwards from filesystem-clients SG"

  from_port                = local.nfs_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.filesystem_clients.id
  to_port                  = local.nfs_port
  type                     = "ingress"
}

resource "aws_security_group_rule" "filesystem_client_nfs_out" {
  security_group_id = aws_security_group.filesystem_clients.id
  description       = "Allow ${local.nfs_port} from filesystem-clients SG to filesystem SG"

  from_port                = local.nfs_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.filesystem.id
  to_port                  = local.nfs_port
  type                     = "egress"
}
