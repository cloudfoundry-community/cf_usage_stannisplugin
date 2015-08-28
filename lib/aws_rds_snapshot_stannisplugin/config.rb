require "yaml"
require "fog"

class Stannis::Plugin::AwsRdsSnapshot::Config
  def self.load_file(path)
    config = YAML.load_file(path)
    new(config)
  end

  def initialize(config)
    @aws_credentials = config["aws"]
  end

  def fog
    @fog ||= Fog::Compute.new({
      provider: 'AWS',
      aws_access_key_id: @aws_credentials["aws_access_key_id"],
      aws_secret_access_key: @aws_credentials["aws_secret_access_key"]
    })
  end
end
