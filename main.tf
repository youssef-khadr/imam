provider "aws" {
  region     = "us-east-1"
  #profile    = "default"
}
terraform {
  backend "s3" {
    bucket   = "yk-imam-terraform-state-files"
    key      = "aurora-migration"
    encrypt  = true
    dynamodb_table = "imam-terraform-lock"
    region   = "us-east-1"
  }
}

## ------------------------------------------------
## Setup Database
## ------------------------------------------------
module "database" {
  source                              = "./database"

  name                                = "aurora-rds-postgres"
  database_name                       = "auroraDB"
  engine                              = "aurora-postgresql"
  engine_version                      = "9.6"
  subnets                             = ["subnet-03f73795a83062a6f","subnet-02b696b70fbc15ac8"]
  vpc_id                              = "vpc-0d910ac93a2912625"
  replica_count                       = 2
  instance_type                       = "db.r5.large"

  enabled_cloudwatch_logs_exports     = ["postgresql"]
  allowed_cidr_blocks                 = ["0.0.0.0/0"]
  create_security_group = true
  db_subnet_group_name = ""
  allowed_security_groups = []
  backup_retention_period = 14
  preferred_backup_window = "11:00-12:00"
  preferred_maintenance_window = "sat:08:00-sat:09:00"
  monitoring_interval = 60
  project  = "IMAM"
  topic_arn = module.sns.topic_arn
}

## ------------------------------------------------
## Setup Terraform Backend
## ------------------------------------------------
module "backend" {
  source                              = "./backend"
  backend_bucket = "yk-imam-terraform-state-files"
  dynamodb_lock_table_name = "imam-terraform-lock"
}

## ------------------------------------------------
## Setup SNS For Database CloudWatch alarms
## ------------------------------------------------
module "sns" {
  source                              = "./sns"
  sns_subscription_emails= ["youssef.khadr@hotmail.com","youssef.khadr@rackspace.com"]
  sns_topic_name = "IMAM_RDS_AURORA_DB"
  sns_topic_display_name=  "Alarm For Imam RDS Aurora DB"

}

## ------------------------------------------------
## Setup DNS Entries For Database
## ------------------------------------------------
module "dns" {
  source                              = "./dns"
  hosted_zone_id = "123"
  dns_writer_record_name = "imamwriter.database.com"
  database_writer_endpoint = module.database.rds_cluster_endpoint
  dns_reader_record_name = "imamreader.database.com"
  database_reader_endpoint = module.database.rds_cluster_reader_endpoint
}

#data "aws_kms_key" "kms_rds_key" {
#  key_id = "alias/aws/rds"
#}
#output "KMS_ARN" {
#  value = "${data.aws_kms_key.kms_rds_key.arn}"
#}
