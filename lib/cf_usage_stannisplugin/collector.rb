class Stannis::Plugin::CfUsage::Collector
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def fetch_deployment_statuses(deployment_config)
    unless deployment_config["cf"] &&
        deployment_config["cf"]["api"] &&
        deployment_config["cf"]["username"] &&
        deployment_config["cf"]["password"]
      err "deployments[] requires cf.api, cf.username, cf.password"
    end
  end

  def err(msg)
    $stderr.puts msg
    exit 1
  end

end
