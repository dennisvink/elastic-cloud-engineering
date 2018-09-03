module DemoStack
  extend ActiveSupport::Concern
  include Rubycfn

  included do
    include DemoStack::CICD
  end
end
