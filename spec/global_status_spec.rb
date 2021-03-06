require "spec_helper"

describe Stannis::Plugin::CfUsage::Status do
  let(:cf_client) { double(Stannis::Plugin::CfUsage::CfClient) }

  describe "global status" do
    describe "apps count" do
      subject { Stannis::Plugin::CfUsage::Status::AppsCount.new(cf_client) }
      before do
        expect(cf_client).to receive(:get).with("/v2/apps?results-per-page=5").
          and_return({"total_results": 500})
        @data = subject.stannis_snapshot_data
      end
      it('found usage data') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("apps deployed") }
      it('has value') { expect(@data.value).to eq(500) }
      it('has indicator') { expect(@data.indicator).to eq("ok") }
    end

    describe "service instances count" do
      subject { Stannis::Plugin::CfUsage::Status::ServiceInstancesCount.new(cf_client) }
      before do
        expect(cf_client).to receive(:get).with("/v2/service_instances?results-per-page=5").
          and_return({"total_results": 400})
        @data = subject.stannis_snapshot_data
      end
      it('found usage data') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("service instances") }
      it('has value') { expect(@data.value).to eq(400) }
      it('has indicator') { expect(@data.indicator).to eq("ok") }
    end
  end

  describe "broker status" do
    describe "service instance count" do
      subject { Stannis::Plugin::CfUsage::Status::ServiceInstancesCount.new(cf_client) }
      before do
        expect(cf_client).to receive(:get).with("/v2/service_instances?results-per-page=5").
          and_return({"total_results": 400})
        @data = subject.stannis_snapshot_data
      end
      it('found usage data') { expect(@data).to_not be_nil }
      it('no validation errors') { expect(@data.validation_errors).to eq([]) }
      it('has label') { expect(@data.label).to eq("service instances") }
      it('has value') { expect(@data.value).to eq(400) }
      it('has indicator') { expect(@data.indicator).to eq("ok") }
    end
  end
end
