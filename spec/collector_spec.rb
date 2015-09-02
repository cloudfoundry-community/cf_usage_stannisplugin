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

  describe "fetches statuses" do
    let(:cf_rds_data) { double(Stannis::Client::DeploymentData) }
    let(:redis_volume_data) { double(Stannis::Client::DeploymentData) }

    it 'for each deployment' do
      expect(subject).to receive(:fetch_deployment_statuses).with(cf_deployment_config).and_return([cf_rds_data])
      expect(subject).to receive(:fetch_deployment_statuses).with(redis_deployment_config).and_return([redis_volume_data])
      expect(subject.fetch_statuses).to eq([cf_rds_data, redis_volume_data])
    end
  end

  describe "fetches status for a deployment" do
    let(:rds_ccdb_data) { double(Stannis::Client::DeploymentData) }
    let(:rds_uaadb_data) { double(Stannis::Client::DeploymentData) }

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

    # it 'with volume snapshots' do
    #   expect(subject.fetch_deployment_statuses(cf_deployment_config)).to eq(volumes_status)
    # end
  end
end
