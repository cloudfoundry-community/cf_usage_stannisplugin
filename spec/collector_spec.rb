require "spec_helper"

describe Stannis::Plugin::CfUsage::Collector do
  let(:config) do
    double(Stannis::Plugin::CfUsage::Config)
  end

  subject { Stannis::Plugin::CfUsage::Collector.new(config) }
end
