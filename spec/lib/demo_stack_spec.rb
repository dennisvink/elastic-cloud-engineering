require "spec_helper"

require "rubycfn"
require "active_support/concern"
require_relative "../../lib/main.rb"

describe Rubycfn do
  module RspecStack
    extend ActiveSupport::Concern
    include Rubycfn

    included do
      description "RSpec Stack"
      include DemoStack::CICD
    end
  end

  CloudFormation = include RspecStack
  RspecStack = CloudFormation.render_template
  Given(:json) { JSON.parse(RspecStack) }

  context "Renders template" do
    let(:template) { json }
    subject { template }

    it { should_not have_key "Parameters" }
    it { should have_key "Resources" }

    context "Has Codebuild Resources" do
      let(:resources) { template["Resources"] }
      subject { resources }

      it { should have_key "CodeBuildDemoProject" }
      it { should have_key "CodeBuildServiceRole" }

      context "Codebuild Repository" do
        let(:repository) { resources["CodeBuildDemoProject"] }
        subject { repository }

        it { should have_key "Properties" }

        context "Codebuild properties" do
          let(:codebuild_properties) { repository["Properties"] }
          subject { codebuild_properties }

          it { should have_key "Artifacts" }
          it { should have_key "Environment" }
          it { should have_key "Name" }
          it { should have_key "ServiceRole" }
          it { should have_key "Source" }
          it { should have_key "TimeoutInMinutes" }
          it { should have_key "Triggers" }

          context "Codebuild Auth Type" do
            let(:auth_type) { codebuild_properties["Source"]["Auth"]["Type"] }
            subject { auth_type }
          
            it { should eq "OAUTH" }
          end

          context "Codebuild creates webhook" do
            let(:webhook) { codebuild_properties["Triggers"]["Webhook"] }
            subject { webhook }

            it { should eq true }
          end
        end
      end

      context "Codebuild Service Role" do
        let(:code_build_service_role) { resources["CodeBuildServiceRole"] }
        subject { code_build_service_role }

        it { should have_key "Properties" }

        context "Code build service role properties" do
          let(:code_build_service_role_properties) { code_build_service_role["Properties"] }
          subject { code_build_service_role_properties }

          it { should have_key "AssumeRolePolicyDocument" }
          it { should have_key "Path" }
          it { should have_key "Policies" }

          context "Code build service role policy document" do
            let(:policy_document) { code_build_service_role_properties["Policies"][0]["PolicyDocument"] }
            subject { policy_document }

            it { should have_key "Statement" }

            context "Code build service role actions" do
              let(:statement) { policy_document["Statement"][0]["Action"] }
              subject { statement }

              it { should eq %w(logs:CreateLogGroup logs:CreateLogStream logs:PutLogEvents) }
            end
          end
        end
      end
    end
  end
end
