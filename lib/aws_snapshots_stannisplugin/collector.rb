class Stannis::Plugin::AwsSnapshots::Collector
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def fetch_statuses
    config.deployments.map do |deployment_config|
      fetch_statuses_for_deployment(deployment_config)
    end
  end

  def fetch_statuses_for_deployment(deployment_config)

  end

  def old_code
    config.deployments.each do |deployment|
      unless deployment["rds"] || deployment["volumes"]
        err "deployments[] requires either rds[] and/or volumes[]"
      end
      if deployment["rds"]
        unless deployment["rds"].is_a?(Array)
          err "Missing config: deployments[].rds[] - #{deployment.inspect}"
        end
        unless (bosh_really_uuid = deployment["bosh_really_uuid"]) &&
          (deployment_name = deployment["deployment_name"]) &&
          (label = deployment["label"])
          err "Required deployment config: bosh_really_uuid, deployment_name, label"
        end

        data = deployment["rds"].map do |rds_snapshots|
          instance_id = rds_snapshots["instance_id"]
          status = Stannis::Plugin::AwsSnapshots::Status.new(config.fog_rds, instance_id)
          snapshot = status.latest_snapshot
          status.stannis_data(snapshot)
        end
        upload_data = {
          "reallyuuid" => bosh_really_uuid,
          "deploymentname" => deployment_name,
          "label" => label,
          "data" => data
        }.to_json

        puts upload_data
        config.stannis.upload_deployment_data(bosh_really_uuid, deployment_name, label, upload_data)
      end
    end

  end

  def err(msg)
    $stderr.puts msg
    exit 1
  end

end
