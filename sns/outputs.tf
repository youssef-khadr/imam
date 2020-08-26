output "topic_arn" {
  value = "${aws_cloudformation_stack.tf_sns_topic.outputs["TopicArn"]}"
}
