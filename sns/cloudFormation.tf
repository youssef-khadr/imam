
resource "aws_cloudformation_stack" "tf_sns_topic" {
   name = "snsStack"
   template_body = data.template_file.aws_cf_sns_stack.rendered
   tags = {
     name = "snsStack"
   }
 }

data "template_file" "aws_cf_sns_stack" {
   template = file("${path.module}/cf_aws_sns_email_stack.json.tpl")
   vars = {
     sns_topic_name        = var.sns_topic_name
     sns_display_name      = var.sns_topic_display_name
     sns_subscription_list = join(",", formatlist("{\"Endpoint\": \"%s\",\"Protocol\": \"%s\"}", var.sns_subscription_emails, "email"))
   }
 }
 

