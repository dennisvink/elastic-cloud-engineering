require "rubycfn"
require "dotenv"

Dotenv.load(".env")
Dotenv.load(".env.private")
Dotenv.load(".env.#{ENV["ENVIRONMENT"]}")

# Include all group concerns
Dir[File.expand_path('../shared_concerns/', __FILE__) + '/*.rb'].sort.each do |file|
  require file
end

# SharedConcerns module is injected in each stack
module SharedConcerns
  extend ActiveSupport::Concern
  include Rubycfn

  included do
    include Concerns::GlobalVariables
  end
end

# Include all stack concerns
Dir[File.expand_path('../stacks/', __FILE__) + '/*.rb'].sort.each do |file|
  subdir = File.basename(file, ".rb") 
  Dir[File.expand_path('../stacks/', __FILE__) + "/#{subdir}/*.rb"].sort.each do |subfile|
    require subfile
  end
  require file
end
