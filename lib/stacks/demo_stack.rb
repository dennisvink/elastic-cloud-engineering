module DemoStack
  extend ActiveSupport::Concern
  include Rubycfn

  included do
    include DemoStack::VPC
    include DemoStack::Codebuild
    #include DemoStack::Lander
  end
end
