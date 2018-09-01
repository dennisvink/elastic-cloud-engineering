module DemoStack
  module Codebuild
    extend ActiveSupport::Concern

    included do

      resource :start_demo_build_log_group,
               type: "AWS::Logs::LogGroup"

      resource :check_demo_build_log_group,
               type: "AWS::Logs::LogGroup"

      resource :builkd_demo_done_log_group,
               type: "AWS::Logs::LogGroup"

      resource :webhook_demo_resource_log_group,
               type: "AWS::Logs::LogGroup"

      resource :iam_role_lambda_execution,
               type: "AWS::IAM::Role" do |r|
        r.property(:assume_role_policy_document) do
          {
	    "Version": "2012-10-17",
	    "Statement": [
	      {
		"Effect": "Allow",
		"Principal": {
		  "Service": [
		    "lambda.amazonaws.com"
		  ]
		},
		"Action": [
		  "sts:AssumeRole"
		]
	      }
	    ]
          }
        end
        r.property(:policies) do
          [
            {
              "PolicyName": %w(trigger github-webhook lambda).fnjoin("-")
            }
          ]
        end
        r.property(:policy_document) do
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": [
                  "logs:CreateLogStream"
                ],
                "Resource":
                  %w(start-build check-build-status build-done webhook-resource).map do |log_group|
                    "arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/lambda/github-webhook-trigger-#{log_group}:*".fnsub
                  end
                
              },
              {
                "Effect": "Allow",
                "Action": [
                  "logs:PutLogEvents"
                ],
                "Resource":
                  %w(start-build check-build-status build-done webhook-resource).map do |log_group|
                    "arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/lambda/github-webhook-trigger-#{log_group}:*".fnsub
                  end
                
              },
              {
                "Effect": "Allow",
                "Action": [
                  "codebuild:*"
                ],
                "Resource": "*"
              }
            ],
            "Path": "/"
          }
        end
      end

    end
  end
end
