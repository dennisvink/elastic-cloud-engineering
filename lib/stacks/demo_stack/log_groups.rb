require 'date'

module DemoStack
  module LogGroups
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
    end
  end
end
