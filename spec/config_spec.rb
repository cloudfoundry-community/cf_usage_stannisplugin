require 'spec_helper'

describe Stannis::Plugin::AwsRdsSnapshot::Config do
  subject {
    example_config = File.expand_path("../../config.example.yml", __FILE__)
    Stannis::Plugin::AwsRdsSnapshot::Config.load_file(example_config)
  }

  it 'has fog Fog::Compute::AWS' do
    expect(subject.fog).not_to be nil
    expect(subject.fog).to be_instance_of(Fog::Compute::AWS::Real)
  end

  it 'maps deployments to RDS usage' do
    expect(subject.deployments).not_to be nil
    expect(subject.deployments.size).to eq(1)
  end
end
