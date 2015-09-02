class Stannis::Plugin::CfUsage::Collector
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def err(msg)
    $stderr.puts msg
    exit 1
  end

end
