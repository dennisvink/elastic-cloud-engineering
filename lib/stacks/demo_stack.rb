module DemoStack
  extend ActiveSupport::Concern
  include Rubycfn

  included do
#    include DemoStack::VPC
#    include DemoStack::LogGroups
    include DemoStack::CICD
#    include DemoStack::ApiGateway
  end
end
