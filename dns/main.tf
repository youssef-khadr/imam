resource "aws_route53_record" "databaseWriter" {
  zone_id = var.hosted_zone_id
  name = var.dns_writer_record_name
  type = "CNAME"
  ttl = "300"
  records = [var.database_writer_endpoint]
}
resource "aws_route53_record" "databaseReader" {
  zone_id = var.hosted_zone_id
  name = var.dns_reader_record_name
  type = "CNAME"
  ttl = "300"
  records = [var.database_reader_endpoint]
}