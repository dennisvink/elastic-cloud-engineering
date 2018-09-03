require 'date'

module DemoStack
  module ApiGateway 
    extend ActiveSupport::Concern

    included do
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

      resource :api_gateway_method_trigger_demo_build_post,
               type: "AWS::ApiGateway::Method" do |r|
        r.property(:http_method) { "POST" }
        r.property(:request_parameters) { }
        r.property(:authorization_type) { "NONE" }
        r.property(:resource_id) { "api_gateway_resource_trigger_demo_build".cfnize.ref }
        r.property(:rest_api_id) { "api_gateway_rest_api".cfnize.ref }
        r.property(:integration) do
          {
            "IntegrationHttpMethod": "POST",
            "Type": "AWS",
            "Credentials": "ApiGatewayToStepFunctionsRole".ref("Arn"),
            "Uri": ["arn:aws:apigateway:", "AWS::Region".ref, ":states:action/StartExecution"].fnjoin,
            "PassthroughBehavior": "NEVER",
            "RequestTemplates": {
              "application/json": [
                "#set( $body = $util.escapeJavaScript($input.json('$')) ) \n\n",
                "{\"input\": \"$body\",\"name\": \"$context.requestId\",\"stateMachineArn\":\"",
                "build_commit_step_functions_state_machine".cfnize.ref,
                "\"}"
              ].fnjoin,
              "application/x-www-form-urlencoded": [
                "#set( $body = $util.escapeJavaScript($input.json('$')) ) \n\n",
                "{\"input\": \"$body\",\"name\": \"$context.requestId\",\"stateMachineArn\":\"",
                "build_commit_step_functions_state_machine".cfnize.ref,
                "\"}"
              ].fnjoin
            },
            "IntegrationResponses": [
              {
                "StatusCode": 200,
                "SelectionPattern": 200,
                "ResponseParameters": {},
                "ResponseTemplates": {}
              },
              {
                "StatusCode": 400,
                "SelectionPattern": 400,
                "ResponseParameters": {},
                "ResponseTemplates": {}
              }
            ] 
          }
        end
        r.property(:method_responses) do
          [
            {
              "ResponseParameters": {},
              "ResponseModels": {},
              "StatusCode": 200
            },
            {
              "ResponseParameters": {},
              "ResponseModels": {},
              "StatusCode": 400
            }
          ]
        end
      end

      resource :api_gateway_to_step_functions_role,
               type: "AWS::IAM::Role" do |r|
        r.property(:assume_role_policy_document) do
          {
            "Version": "2012-10-17",
            "Statement":
              [ 
                {
                  "Effect": "Allow",
                  "Principal": {
                    "Service": "apigateway.amazonaws.com"
                  },
                  "Action": "sts:AssumeRole"
                }
              ]
          }
        end
        r.property(:policies) do
          [
            {
              "PolicyName": "apigatewaytostepfunctions",
              "PolicyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                  {
                    "Effect": "Allow",
                    "Action": [
                      "states:StartExecution"
                    ],
                    "Resource": "*"
                  }
                ]
              }
            }
          ]
        end
      end

      # Resource name with latest unix timestamp
      resource "api_gateway_deployment_#{DateTime.now.strftime('%Q')}".cfnize,
               type: "AWS::ApiGateway::Deployment" do |r|
        r.depends_on "api_gateway_method_trigger_demo_build_post".cfnize
        r.property(:rest_api_id) { "api_gateway_rest_api".cfnize.ref }
        r.property(:stage_name) { "trigger" }
      end
    end
  end
end
