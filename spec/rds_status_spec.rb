require "spec_helper"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"

describe Stannis::Plugin::AwsSnapshots::RDS::Status do
  let(:fog_rds) { double(Fog::AWS::RDS::Real) }
  let(:instance_id) { "cf-db" }
  let(:yesterday) { 1.day.ago }
  subject { Stannis::Plugin::AwsSnapshots::RDS::Status.new(fog_rds, instance_id) }

  describe 'latest snapshot' do
    it 'fetches' do
      snapshots = double(Fog::AWS::RDS::Snapshots)
      expect(fog_rds).to receive(:snapshots).and_return(snapshots)
      expect(snapshots).to receive(:all).with(identifier: instance_id).
        and_return([
          double(Fog::AWS::RDS::Snapshot, instance_id: "cf-db", created_at: 2.days.ago),
          double(Fog::AWS::RDS::Snapshot, instance_id: "cf-db", created_at: yesterday),
        ])
      latest = subject.latest_snapshot
      expect(latest).to_not be_nil
      expect(latest.instance_id).to eq("cf-db")
      expect(latest.created_at).to eq(yesterday)
    end
  end

  describe 'packaging for Stannis::Client' do
    describe 'existing snapshots' do
      let(:snapshot) { double(Fog::AWS::RDS::Snapshot, instance_id: "cf-db", created_at: yesterday) }
      before { @data = subject.stannis_data(snapshot) }
      it('for found snapshot') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("RDS snapshot cf-db") }
      it('has value') { expect(@data.value).to eq("1 day ago") }
      it('has indicator') { expect(@data.indicator).to eq("ok") }
    end

    describe 'no snapshots' do
      before { @data = subject.stannis_data(nil) }
      it('for missing snapshot') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("RDS snapshot cf-db") }
      it('has "missing" value') { expect(@data.value).to eq("missing") }
      it('has indicator') { expect(@data.indicator).to eq("down") }
    end
  end
end
