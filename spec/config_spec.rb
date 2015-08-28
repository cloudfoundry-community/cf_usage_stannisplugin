require 'spec_helper'

describe Stannis::Plugin::AwsRdsSnapshot::Config do
  subject {
    example_config = File.expand_path("../../config.example.yml", __FILE__)
    Stannis::Plugin::AwsRdsSnapshot::Config.load_file(example_config)
  }

  it 'has fog_compute Fog::Compute::AWS' do
    expect(subject.fog_compute).not_to be nil
    expect(subject.fog_compute).to be_instance_of(Fog::Compute::AWS::Real)
  end

  it 'has fog_rds Fog::AWS::RDS' do
    expect(subject.fog_rds).not_to be nil
    expect(subject.fog_rds).to be_instance_of(Fog::AWS::RDS::Real)
  end

  it 'has stannis client' do
    expect(subject.stannis).not_to be nil
    expect(subject.stannis).to be_instance_of(Stannis::Client)
  end

  it 'maps deployments to RDS usage' do
    expect(subject.deployments).not_to be nil
    expect(subject.deployments.size).to eq(1)
  end
end
