require "spec_helper"

describe Stannis::Plugin::AwsSnapshots::Collector do
  let(:cf_deployment_config) do
    {
      "deployment_name" => "cf",
      "rds" => [
        {"instance_id" => "rds-cf-ccdb"},
        {"instance_id" => "rds-cf-uaadb"}
      ]
    }
  end
  let(:redis_deployment_config) do
    {
      "deployment_name" => "redis",
      "volumes" => [
        {"description_regexp" => "^redis"}
      ]
    }
  end
  let(:config) do
    double(Stannis::Plugin::AwsSnapshots::Config,
      deployments: [cf_deployment_config, redis_deployment_config])
  end

  subject { Stannis::Plugin::AwsSnapshots::Collector.new(config) }

  describe "fetches status for a deployment" do
    let(:rds_ccdb_data) { double(Stannis::Client::DeploymentData) }
    let(:rds_uaadb_data) { double(Stannis::Client::DeploymentData) }
    let(:redis_volume_data) { double(Stannis::Client::DeploymentData) }

    it 'with RDS snapshots' do
      expect(subject).to receive(:fetch_status_rds).with({"instance_id" => "rds-cf-ccdb"}).and_return(rds_ccdb_data)
      expect(subject).to receive(:fetch_status_rds).with({"instance_id" => "rds-cf-uaadb"}).and_return(rds_uaadb_data)
      expect(subject.fetch_deployment_statuses(cf_deployment_config)).to eq([rds_ccdb_data, rds_uaadb_data])
    end

    it 'fetches an RDS snapshot' do
      snapshot_status_cmd = double(Stannis::Plugin::AwsSnapshots::RDS::SnapshotStatus)
      expect(subject).to receive(:rds_snapshot_status).and_return(snapshot_status_cmd)
      expect(snapshot_status_cmd).to receive(:stannis_snapshot_data).with("rds-cf-ccdb").and_return(rds_ccdb_data)
      expect(subject.fetch_status_rds({"instance_id" => "rds-cf-ccdb"})).to eq(rds_ccdb_data)
    end

    it 'with volume snapshots' do
      snapshot_status_cmd = double(Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus)
      expect(subject).to receive(:volume_snapshot_status).and_return(snapshot_status_cmd)
      expect(snapshot_status_cmd).to receive(:stannis_snapshot_data).with(/redis/).and_return(redis_volume_data)
      expect(subject.fetch_volume_snapshot_status({"description_regexp" => "redis"})).to eq(redis_volume_data)
    end
  end
end
