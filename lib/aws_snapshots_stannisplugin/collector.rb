class Stannis::Plugin::AwsSnapshots::Collector
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def fetch_deployment_statuses(deployment_config)
    unless deployment_config["rds"] || deployment_config["volumes"]
      err "deployments[] requires either rds[] and/or volumes[]"
    end

    extra_data = []
    if deployment_config["rds"]
      if !deployment_config["rds"].is_a?(Array)
        err 'deployments[].rds must be an array of {instance_id: "name"}'
      end
      deployment_config["rds"].each do |rds_config|
        extra_data << fetch_status_rds(rds_config)
      end
    end

    if deployment_config["volumes"]
      if !deployment_config["volumes"].is_a?(Array)
        err 'deployments[].volumes must be an array of {description_regexp: "regexp"}'
      end
      deployment_config["volumes"].each do |volume_config|
        extra_data << fetch_volume_snapshot_status(volume_config)
      end
    end
    extra_data
  end

  def fetch_status_rds(rds_config)
    unless instance_id = rds_config["instance_id"]
      err "RDS config requires instance_id"
    end
    rds_snapshot_status.stannis_snapshot_data(instance_id)
  end

  def rds_snapshot_status
    @rds_snapshot_status ||= Stannis::Plugin::AwsSnapshots::RDS::SnapshotStatus.new(config.fog_rds)
  end

  def fetch_volume_snapshot_status(volume_config)
    unless regexp_str = volume_config["description_regexp"]
      err "Volume config requires description_regexp"
    end
    regexp = Regexp.new(regexp_str)
    volume_snapshot_status.stannis_snapshot_data(regexp)
  end

  def volume_snapshot_status
    @volume_snapshot_status ||= Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus.new(config.fog_compute)
  end

  def old_code
    config.deployments.each do |deployment|
      if deployment["rds"]

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
