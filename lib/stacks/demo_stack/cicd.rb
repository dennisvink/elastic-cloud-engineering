module DemoStack
  module CICD
    extend ActiveSupport::Concern

    included do
      parameter :github_repository,
                default: "https://github.com/dennisvink/elastic-cloud-engineering/",
                type: "String"

      resource :code_build_service_role,
               type: "AWS::IAM::Role" do |r|
        r.property(:assume_role_policy_document) do
          {
	    "Version": "2012-10-17",
	    "Statement": [
	      {
		"Effect": "Allow",
		"Principal": {
		  "Service": [
		    "codebuild.amazonaws.com"
		  ]
		},
		"Action": [
		  "sts:AssumeRole"
		]
	      }
	    ]
          }
        end
        r.property(:path) { "/service-role/" }
        r.property(:policies) do
          [
            {
              "PolicyName": "CodeBuildAccessPolicies",
              "PolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Action": [
                            "logs:CreateLogGroup",
                            "logs:CreateLogStream",
                            "logs:PutLogEvents"
                        ],
                        "Resource": [
                          "arn:aws:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/codebuild/*".fnsub
                        ]
                    }
                ]
              }
            }
          ]
        end
      end

      resource :code_build_demo_project,
               type: "AWS::CodeBuild::Project" do |r|
        r.property(:name) { "demo-project-${AWS::Region}-${AWS::StackName}".fnsub }
        r.property(:service_role) { "code_build_service_role".cfnize.ref("Arn") }
        r.property(:artifacts) do
          {
            "Type": "no_artifacts"
          }
        end
        r.property(:environment) do
          {
            "Type": "LINUX_CONTAINER",
            "ComputeType": "BUILD_GENERAL1_SMALL",
            "Image": "aws/codebuild/ruby:2.3.1"
          }
        end
        r.property(:source) do
          {
            "BuildSpec": text = File.read("config/buildspec.yml"),
            "Auth": {
              "Type": "OAUTH"
            },
            "Location": "github_repository".cfnize.ref,
            "Type": "GITHUB"
          }
        end
        r.property(:triggers) do
          {
            "Webhook": true
          }
        end
        r.property(:timeout_in_minutes) { 10 }
      end
    end
  end
end
