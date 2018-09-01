module DemoStack
  module Lander
    extend ActiveSupport::Concern

    included do

      # Bucket for our landing page
      resource :demo_s3_bucket,
               type: "AWS::S3::Bucket"

    end
  end
end
