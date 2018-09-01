module DemoStack
  module VPC
    extend ActiveSupport::Concern

    included do

      variable :cidr_block,
               default: "10.0.0.0/16"

      resource :demo_vpc,
               type: RubyCfn::VPC do |r|
        r.set(:cidr_block) { cidr_block }
      end

    end
  end
end
