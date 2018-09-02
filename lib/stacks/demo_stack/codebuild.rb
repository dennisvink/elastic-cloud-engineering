module DemoStack
  module Codebuild
    extend ActiveSupport::Concern

    included do

      resource :start_demo_build_log_group,
               type: "AWS::Logs::LogGroup"

      resource :check_build_log_group,
               type: "AWS::Logs::LogGroup"

      resource :build_done_log_group,
               type: "AWS::Logs::LogGroup"

      resource :webhook_resource_log_group,
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

      resource :check_build_status_lambda_function,
                type: "AWS::Lambda::Function" do |r|
        r.depends_on %w(IamRoleLambdaExecution CheckBuildLogGroup)
        r.property(:code) do
          {
            "S3Bucket": "github-webhook-artifacts-${AWS::Region}".fnsub,
            "S3Key": "serverless/github-webhook/trigger/1494342303416-2017-05-09T15:05:03.416Z/github-webhook.zip"
          }
        end
        r.property(:function_name) { "${AWS::StackName}-trigger-check-build-status".fnsub }
        r.property(:handler) { "handler.check_build_status" }
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

      resource :build_done_lambda_function,
                type: "AWS::Lambda::Function" do |r|
        r.depends_on %w(IamRoleLambdaExecution BuildDoneLogGroup)
        r.property(:code) do
          {
            "S3Bucket": "github-webhook-artifacts-${AWS::Region}".fnsub,
            "S3Key": "serverless/github-webhook/trigger/1494342303416-2017-05-09T15:05:03.416Z/github-webhook.zip"
          }
        end
        r.property(:function_name) { "${AWS::StackName}-trigger-build-done".fnsub }
        r.property(:handler) { "handler.build_done" }
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

      resource :webhook_resource_lambda_function,
                type: "AWS::Lambda::Function" do |r|
        r.depends_on %w(IamRoleLambdaExecution WebhookResourceLogGroup)
        r.property(:code) do
          {
            "S3Bucket": "github-webhook-artifacts-${AWS::Region}".fnsub,
            "S3Key": "serverless/github-webhook/trigger/1494342303416-2017-05-09T15:05:03.416Z/github-webhook.zip"
          }
        end
        r.property(:function_name) { "${AWS::StackName}-trigger-webhook-resource".fnsub }
        r.property(:handler) { "webhook.resource" }
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

      resource :iam_role_state_machine_execution,
               type: "AWS::IAM::Role" do |r|
        r.property(:assume_role_policy_document) do
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Principal": {
                  "Service": "states.${AWS::Region}.amazonaws.com".fnsub 
                },
                "Action": "sts:AssumeRole"
              }
            ]
          }
        end
        r.property(:policies) do
          [
            {
              "PolicyName": "trigger-${AWS::Region}-github-webhook-statemachine".fnsub,
              "PolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                  {
                    "Effect": "Allow",
                    "Action": %w(lambda:InvokeFunction),
                    "Resource": "*"
                  }
                ]
              }
            }
          ]
        end
      end

      resource :build_commit_step_functions_state_machine,
               type: "AWS::StepFunctions::StateMachine" do |r|
        r.depends_on %w(IamRoleStateMachineExecution)
        r.property(:definition_string) { "{\"Comment\":\"Check for build status for the given build project, and mark it when done on GH\",\"StartAt\":\"start_build\",\"States\":{\"start_build\":{\"Type\":\"Task\",\"Resource\":\"arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:${AWS::StackName}-trigger-start-build\",\"Next\":\"check_build_status\"},\"wait_a_bit\":{\"Type\":\"Wait\",\"Seconds\":5,\"Next\":\"check_build_status\"},\"check_build_status\":{\"Type\":\"Task\",\"Resource\":\"arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:${AWS::StackName}-trigger-check-build-status\",\"Next\":\"check_build_status_outcome\"},\"check_build_status_outcome\":{\"Type\":\"Choice\",\"Choices\":[{\"Variable\":\"$.buildComplete\",\"BooleanEquals\":true,\"Next\":\"build_done\"}],\"Default\":\"wait_a_bit\"},\"build_done\":{\"Type\":\"Task\",\"Resource\":\"arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:${AWS::StackName}-trigger-build-done\",\"End\":true}}}".fnsub }
        r.property(:role_arn) { "iam_role_state_machine_execution".cfnize.ref("Arn") }
      end

      resource :api_gateway_rest_api,
               type: "AWS::ApiGateway::RestApi" do |r|
        r.property(:name) { "trigger-github-webhook" }
      end

      resource :api_gateway_resource_trigger_demo_build,
               type: "AWS::ApiGateway::Resource" do |r|
        r.property(:parent_id) { "ApiGatewayRestApi".ref("RootResourceId") }
        r.property(:path_part) { "trigger-build" }
        r.property(:rest_api_id) { "ApiGatewayRestApi".ref }
      end
    end
  end
end
