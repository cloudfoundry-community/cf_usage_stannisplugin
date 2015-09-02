require "spec_helper"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"

describe Stannis::Plugin::AwsSnapshots::RDS::SnapshotStatus do
  let(:fog_rds) { double(Fog::AWS::RDS::Real) }
  let(:instance_id) { "cf-db" }
  let(:yesterday) { 1.day.ago }
  subject { Stannis::Plugin::AwsSnapshots::RDS::SnapshotStatus.new(fog_rds) }

  describe 'latest snapshot' do
    let(:snapshots) { double(Fog::AWS::RDS::Snapshots) }
    before do
      expect(fog_rds).to receive(:snapshots).and_return(snapshots)
    end
    describe 'exists' do
      before do
        expect(snapshots).to receive(:all).with(identifier: instance_id).
          and_return([
            double(Fog::AWS::RDS::Snapshot, instance_id: instance_id, created_at: 2.days.ago),
            double(Fog::AWS::RDS::Snapshot, instance_id: instance_id, created_at: yesterday),
          ])
        @data = subject.stannis_snapshot_data(instance_id)
      end
      it('for found snapshot') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("RDS snapshot cf-db") }
      it('has value') { expect(@data.value).to eq("1 day ago") }
      it('has indicator') { expect(@data.indicator).to eq("ok") }
    end

    describe 'no snapshots' do
      before do
        expect(snapshots).to receive(:all).with(identifier: "unknown").
          and_return([])
        @data = subject.stannis_snapshot_data("unknown")
      end
      it('for missing snapshot') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("RDS snapshot unknown") }
      it('has "missing" value') { expect(@data.value).to eq("missing") }
      it('has indicator') { expect(@data.indicator).to eq("down") }
    end
  end
end
