class Stannis::Plugin::CfUsage::Status::ServiceInstancesCount
  attr_reader :cf_client

  def initialize(cf_client)
    @cf_client = cf_client
  end

  def stannis_snapshot_data
    count = cf_apps_deployed
    Stannis::Client::DeploymentData.new("service instances", count)
  end

  def cf_apps_deployed
    apps = cf_client.get("/v2/service_instances?results-per-page=5")
    apps["total_results"] || apps[:total_results]
  end
end
