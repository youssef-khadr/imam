{
  "Resources": {
    "SNSTopic": {
      "Type": "AWS::SNS::Topic",
      "Properties": {
        "TopicName": "${sns_topic_name}",
        "DisplayName": "${sns_display_name}",
        "Subscription": [${sns_subscription_list}] 
      }
    }
  },
  "Outputs" : {
    "TopicArn" : {
      "Description" : "Topic ARN",
      "Value" : { "Ref" : "SNSTopic" }
    }
  }
}
