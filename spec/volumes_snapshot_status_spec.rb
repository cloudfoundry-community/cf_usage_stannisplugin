require "spec_helper"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"

describe Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus do
  let(:fog_compute) { double(Fog::Compute::AWS::Real) }
  let(:yesterday) { 1.day.ago }
  subject { Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus.new(fog_compute) }

  describe 'latest' do
    before do
      expect(fog_compute).to receive(:snapshots).and_return([
          double(Fog::Compute::AWS::Snapshot, description: "r2 microbosh snapshot two days ago", created_at: 2.days.ago),
          double(Fog::Compute::AWS::Snapshot, description: "r2 microbosh snapshot yesterday", created_at: yesterday),
          double(Fog::Compute::AWS::Snapshot, description: nil, created_at: yesterday),
          double(Fog::Compute::AWS::Snapshot, description: "unrelated", created_at: yesterday),
        ])
    end

    describe 'existing snapshots' do
      before do
        @data = subject.stannis_snapshot_data(/^r2 microbosh/)
      end
      it('for found snapshot') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("Volume snapshot r2 microbosh snapshot yesterday") }
      it('has value') { expect(@data.value).to eq("1 day ago") }
      it('has indicator') { expect(@data.indicator).to eq("ok") }
    end

    describe 'no snapshots' do
      before do
        @data = subject.stannis_snapshot_data(/unknown/)
      end
      it('for missing snapshot') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("Volume snapshot /unknown/") }
      it('has "missing" value') { expect(@data.value).to eq("missing") }
      it('has indicator') { expect(@data.indicator).to eq("down") }
    end
  end
end
