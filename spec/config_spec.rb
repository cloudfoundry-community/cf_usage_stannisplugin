require 'spec_helper'

describe Stannis::Plugin::CfUsage::Config do
  subject {
    example_config = File.expand_path("../../config.example.yml", __FILE__)
    Stannis::Plugin::CfUsage::Config.load_file(example_config)
  }

  it 'has stannis client' do
    expect(subject.stannis).not_to be nil
    expect(subject.stannis).to be_instance_of(Stannis::Client)
  end

  it 'has cf client' do
    expect(subject.cf).to be_instance_of(Stannis::Plugin::CfUsage::CfClient)
  end
end
