require "spec_helper"

describe Stannis::Plugin::AwsSnapshots::Collector do
  let(:cf_redis_deployment_config) { {"deployment_name" => "cf"} }
  let(:redis_deployment_config2) { {"deployment_name" => "redis"} }
  let(:config) do
    double(Stannis::Plugin::AwsSnapshots::Config,
      deployments: [cf_redis_deployment_config, redis_deployment_config2])
  end
  subject { Stannis::Plugin::AwsSnapshots::Collector.new(config) }
  let(:cf_data) { double(Stannis::Client::DeploymentData) }
  let(:redis_data) { double(Stannis::Client::DeploymentData) }
  it 'fetches statuses for each deployment' do
    expect(subject).to receive(:fetch_statuses_for_deployment).with(cf_redis_deployment_config).and_return(cf_data)
    expect(subject).to receive(:fetch_statuses_for_deployment).with(redis_deployment_config2).and_return(redis_data)
    expect(subject.fetch_statuses).to eq([cf_data, redis_data])
  end

end
