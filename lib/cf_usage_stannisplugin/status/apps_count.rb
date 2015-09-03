class Stannis::Plugin::CfUsage::Status::AppsCount
  attr_reader :cf_client

  def initialize(cf_client)
    @cf_client = cf_client
  end

  def stannis_snapshot_data
    count = cf_apps_deployed
    Stannis::Client::DeploymentData.new("apps deployed", count)
  end

  def cf_apps_deployed
    apps = cf_client.get("/v2/apps?results-per-page=5")
    apps[:total_results]
  end
end
