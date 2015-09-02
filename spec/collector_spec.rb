require "spec_helper"

describe Stannis::Plugin::AwsSnapshots::Collector do
  let(:config) { double(Stannis::Plugin::AwsSnapshots::Config) }
  subject { Stannis::Plugin::AwsSnapshots::Collector.new(config) }
  it 'fetches statuses for each deployment' do
    cf_redis_deployment_config = {"deployment_name" => "cf"}
    redis_deployment_config2 = {"deployment_name" => "redis"}
    cf_data = double(Stannis::Client::DeploymentData)
    redis_data = double(Stannis::Client::DeploymentData)
    expect(config).to receive(:deployments).and_return([cf_redis_deployment_config, redis_deployment_config2])
    expect(subject).to receive(:fetch_statuses_for_deployment).with(cf_redis_deployment_config).and_return(cf_data)
    expect(subject).to receive(:fetch_statuses_for_deployment).with(redis_deployment_config2).and_return(redis_data)
    expect(subject.fetch_statuses).to eq([cf_data, redis_data])
  end
end
