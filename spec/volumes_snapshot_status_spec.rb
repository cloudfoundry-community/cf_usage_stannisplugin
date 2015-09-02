require "spec_helper"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"

describe Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus do
  let(:fog_compute) { double(Fog::Compute::AWS::Real) }
  let(:yesterday) { 1.day.ago }
  subject { Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus.new(fog_compute, /^r2 microbosh/) }

  describe 'latest snapshot' do
    it 'fetches' do
      snapshots = double(Fog::Compute::AWS::Snapshots)
      expect(fog_compute).to receive(:snapshots).and_return([
          double(Fog::Compute::AWS::Snapshot, description: "r2 microbosh snapshot two days ago", created_at: 2.days.ago),
          double(Fog::Compute::AWS::Snapshot, description: "r2 microbosh snapshot yesterday", created_at: yesterday),
          double(Fog::Compute::AWS::Snapshot, description: nil, created_at: yesterday),
          double(Fog::Compute::AWS::Snapshot, description: "unrelated", created_at: yesterday),
        ])
      latest = subject.latest_snapshot
      expect(latest).to_not be_nil
      expect(latest.description).to eq("r2 microbosh snapshot yesterday")
      expect(latest.created_at).to eq(yesterday)
    end
  end

  # describe 'packaging for Stannis::Client' do
  #   describe 'existing snapshots' do
  #     let(:snapshot) { double(Fog::AWS::RDS::Snapshot, instance_id: "cf-db", created_at: yesterday) }
  #     before { @data = subject.stannis_data(snapshot) }
  #     it('for found snapshot') { expect(@data).to_not be_nil }
  #     it('no validation errors') { expect(@data.validation_errors).to eq([]) }
  #     it('has label') { expect(@data.label).to eq("RDS snapshot cf-db") }
  #     it('has value') { expect(@data.value).to eq("1 day ago") }
  #     it('has indicator') { expect(@data.indicator).to eq("ok") }
  #   end
  #
  #   describe 'no snapshots' do
  #     before { @data = subject.stannis_data(nil) }
  #     it('for missing snapshot') { expect(@data).to_not be_nil }
  #     it('no validation errors') { expect(@data.validation_errors).to eq([]) }
  #     it('has label') { expect(@data.label).to eq("RDS snapshot cf-db") }
  #     it('has "missing" value') { expect(@data.value).to eq("missing") }
  #     it('has indicator') { expect(@data.indicator).to eq("down") }
  #   end
  # end
end
