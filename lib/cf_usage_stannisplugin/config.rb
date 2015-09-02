require "yaml"
require "fog"

class Stannis::Plugin::CfUsage::Config
  attr_reader :stannis
  attr_reader :deployments

  def self.load_file(path)
    config = YAML.load_file(path)
    new(config)
  end

  def initialize(config)
    @deployments = config["deployments"]
    @stannis = Stannis::Client.new(config["stannis"])
  end

end
