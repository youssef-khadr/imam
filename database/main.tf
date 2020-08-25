locals {
  port                 = "5432"
  master_password      = var.password == "" ? random_password.master_password.result : var.password
  db_subnet_group_name = var.db_subnet_group_name == "" ? join("", aws_db_subnet_group.this.*.name) : var.db_subnet_group_name
 
  rds_enhanced_monitoring_arn  = join("", aws_iam_role.rds_enhanced_monitoring.*.arn)
  rds_enhanced_monitoring_name = join("", aws_iam_role.rds_enhanced_monitoring.*.name)

  rds_security_group_id = join("", aws_security_group.this.*.id)

  default_tags = "${map(
    "Project","${var.project}",
  )}"
}

# Random string to use as master password unless one is specified
resource "random_password" "master_password" {
  length  = 10
  special = false
}

resource "aws_db_subnet_group" "this" {
  count = var.db_subnet_group_name == "" ? 1 : 0

  name        = var.name
  description = "For Aurora cluster ${var.name}"
  subnet_ids  = var.subnets

  tags            = "${merge(
       local.default_tags,
       map(
         "Name", "${var.name}"
       )
     )}"   
}
 
resource "aws_rds_cluster" "this" {
  cluster_identifier                  = var.name
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
#  kms_key_id                          = var.kms_key_id
  database_name                       = var.database_name
  master_username                     = var.username
  master_password                     = local.master_password
#  final_snapshot_identifier           = "${var.final_snapshot_identifier_prefix}-${var.name}-${random_id.snapshot_identifier.hex}"
  skip_final_snapshot                 = true
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = local.port
  db_subnet_group_name                = local.db_subnet_group_name
  vpc_security_group_ids              = compact(concat(aws_security_group.this.*.id, var.vpc_security_group_ids))
#  storage_encrypted                   = var.storage_encrypted
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  storage_encrypted = true
}

resource "aws_rds_cluster_instance" "this" {
  count = var.replica_count

  identifier                      = "${var.name}-${count.index + 1}"
  cluster_identifier              = aws_rds_cluster.this.id
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_type
  db_subnet_group_name            = local.db_subnet_group_name
  
  preferred_maintenance_window    = var.preferred_maintenance_window
  monitoring_role_arn             = local.rds_enhanced_monitoring_arn
  monitoring_interval             = var.monitoring_interval
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  promotion_tier                  = count.index + 1

  tags            = "${merge(
       local.default_tags,
       map(
         "Name", "DB Cluster Instance"
       )
     )}" 
}


data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name               = "rds-enhanced-monitoring-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.monitoring_rds_assume_role.json

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = local.rds_enhanced_monitoring_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-"
  vpc_id      = var.vpc_id

  description = var.security_group_description == "" ? "Control traffic to/from RDS Aurora ${var.name}" : var.security_group_description

  tags            = "${merge(
       local.default_tags,
       map(
         "Name", "RDS Security Group"
       )
     )}"  
}

resource "aws_security_group_rule" "default_ingress" {
  count = var.create_security_group ? length(var.allowed_security_groups) : 0

  description = "From allowed SGs"

  type                     = "ingress"
  from_port                = aws_rds_cluster.this.port
  to_port                  = aws_rds_cluster.this.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = local.rds_security_group_id
}

resource "aws_security_group_rule" "cidr_ingress" {
  count = var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = aws_rds_cluster.this.port
  to_port           = aws_rds_cluster.this.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = local.rds_security_group_id
}

resource "aws_ssm_parameter" "poc_db_username" {
  name        = "POC_DB_USERNAME"
  description = "DB Username "
  type        = "SecureString"
  value       = "${aws_rds_cluster.this.master_username}"
 # key_id      = var.kms_key_id
  tags            = "${merge(
       local.default_tags,
       map(
         "Name", "SSM poc_db_username"
       )
     )}"  
}

resource "aws_ssm_parameter" "poc_db_password" {
  name        = "POC_DB_PASSWORD"
  description = "DB Password "
  type        = "SecureString"
  value       = "${aws_rds_cluster.this.master_password}"
 # key_id      = var.kms_key_id
  tags            = "${merge(
       local.default_tags,
       map(
         "Name", "SSM poc_db_password"
       )
     )}"  
}