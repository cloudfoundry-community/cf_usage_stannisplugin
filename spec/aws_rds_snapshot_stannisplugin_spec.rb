require 'spec_helper'

describe Stannis::Plugin::AwsRdsSnapshot do
  it 'has a version number' do
    expect(Stannis::Plugin::AwsRdsSnapshot::VERSION).not_to be nil
  end
end
