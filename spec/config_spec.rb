require 'spec_helper'

describe Stannis::Plugin::AwsRdsSnapshot::Config do
  subject {
    example_config = File.expand_path("../../config.example.yml", __FILE__)
    Stannis::Plugin::AwsRdsSnapshot::Config.load_file(example_config)
  }

  it 'loads example config' do
    expect(subject.fog).not_to be nil
  end
end
