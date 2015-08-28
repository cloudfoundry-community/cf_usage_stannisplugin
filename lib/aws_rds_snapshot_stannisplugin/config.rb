require "yaml"
require "fog"

class Stannis::Plugin::AwsRdsSnapshot::Config
  attr_reader :stannis
  attr_reader :deployments

  def self.load_file(path)
    config = YAML.load_file(path)
    new(config)
  end

  def initialize(config)
    @aws_credentials = config["aws"]
    @deployments = config["deployments"]
    @stannis = Stannis::Client.new(config["stannis"])
  end

  def fog_compute
    @fog_compute ||= Fog::Compute.new({
      provider: 'AWS',
      aws_access_key_id: @aws_credentials["aws_access_key_id"],
      aws_secret_access_key: @aws_credentials["aws_secret_access_key"]
    })
    # TODO: need region
  end

  def fog_rds
    @fog_rds ||= Fog::AWS::RDS.new({
      aws_access_key_id: @aws_credentials["aws_access_key_id"],
      aws_secret_access_key: @aws_credentials["aws_secret_access_key"]
    })
    # TODO: need region
  end
end
