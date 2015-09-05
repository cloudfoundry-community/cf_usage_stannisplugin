class Stannis::Plugin::CfUsage::Collector
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def fetch_deployment_statuses(deployment_config)
    cf_config = deployment_config["cf"]
    unless cf_config &&
        cf_config["api"] &&
        cf_config["username"] &&
        cf_config["password"]
      err "deployments[] requires cf.api, cf.username, cf.password"
    end
    cf_client = Stannis::Plugin::CfUsage::CfClient.new(cf_config)
    cf_client.login

    extra_data = []
    if service_broker = deployment_config["service_broker"]
      broker_client = Stannis::Plugin::CfUsage::ServiceBrokerClient.new(service_broker)
      extra_data = fetch_service_broker_status(cf_client, broker_client)
    else
      # assume it is for a CF deployment; fetch total numbers
      extra_data << fetch_apps_count(cf_client)
      extra_data << fetch_service_instances_count(cf_client)
    end
    extra_data
  end

  def fetch_service_broker_status(cf_client, broker_client)
    []
  end

  def fetch_apps_count(cf_client)
    Stannis::Plugin::CfUsage::Status::AppsCount.new(cf_client).stannis_snapshot_data
  end

  def fetch_service_instances_count(cf_client)
    Stannis::Plugin::CfUsage::Status::ServiceInstancesCount.new(cf_client).stannis_snapshot_data
  end

  def err(msg)
    $stderr.puts msg
    exit 1
  end

end
