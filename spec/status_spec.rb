require "spec_helper"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"

describe Stannis::Plugin::AwsRdsSnapshot::Status do
  let(:fog_rds) { double(Fog::AWS::RDS::Real) }
  let(:instance_id) { "cf-db" }
  let(:yesterday) { 1.day.ago }
  subject { Stannis::Plugin::AwsRdsSnapshot::Status.new(fog_rds, instance_id) }

  it 'fetches latest snapshot' do
    expect(fog_rds).to receive(:snapshots).and_return([
      double(Fog::AWS::RDS::Snapshot, instance_id: "random-thing"),
      double(Fog::AWS::RDS::Snapshot, instance_id: "cf-db", created_at: 2.days.ago),
      double(Fog::AWS::RDS::Snapshot, instance_id: "cf-db", created_at: yesterday),
    ])
    latest = subject.latest_snapshot
    expect(latest).to_not be_nil
    expect(latest.instance_id).to eq("cf-db")
    expect(latest.created_at).to eq(yesterday)
  end
end
