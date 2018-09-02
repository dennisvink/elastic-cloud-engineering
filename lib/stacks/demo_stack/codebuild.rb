module DemoStack
  module Codebuild
    extend ActiveSupport::Concern

    included do

      resource :start_demo_build_log_group,
               type: "AWS::Logs::LogGroup"

      resource :check_demo_build_log_group,
               type: "AWS::Logs::LogGroup"

      resource :build_demo_done_log_group,
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
              "PolicyName": %w(trigger github-webhook lambda).fnjoin("-"),
              "PolicyDocument": {
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
              }
            }
          ]
        end
        r.property(:path) { "/" }
      end

      resource :start_demo_build_lambda_function,
                type: "AWS::Lambda::Function" do |r|
        r.depends_on %w(IamRoleLambdaExecution StartDemoBuildLogGroup)
        r.property(:code) do
          {
            "S3Bucket": "github-webhook-artifacts-${AWS::Region}".fnsub,
            "S3Key": "serverless/github-webhook/trigger/1494342303416-2017-05-09T15:05:03.416Z/github-webhook.zip"
          }
        end
        r.property(:function_name) { "${AWS::StackName}-trigger-start-build".fnsub }
        r.property(:handler) { "handler.start_build" }
        r.property(:memory_size) { 1024 }
        r.property(:role) { "iam_role_lambda_execution".cfnize.ref("Arn") }
        r.property(:runtime) { "nodejs6.10" }
        r.property(:timeout) { 6 }
        r.property(:environment) do
          {
            "Variables": {
              "BUILD_PROJECT": "Foo",
              "GITHUB_USERNAME": "Bar",
              "GITHUB_ACCESS_TOKEN": "Foobar",
              "GITHUB_REPOSITORY": "Foofoobar"
            }
          }
        end
      end
    end
  end
end
