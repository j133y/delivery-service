require 'rails_helper'

describe ApiConstraints do
  let(:api_constraints_v1) { ApiConstraints.new(version: 1) }
  let(:api_constraints_v2) { ApiConstraints.new(version: 2, default: true) }

  describe "#matches?" do
    context "when the version matches the 'Accept' header" do
      it "returns true " do
        request = double(headers: { "Accept" => "application/vnd.delivery.v1" })

        expect(api_constraints_v1.matches?(request)).to be_truthy
      end
    end

    context "when 'default' option is specified" do
      it "returns the default version " do
        request = double(host: 'api.marketplace.dev')

        expect(api_constraints_v2.matches?(request)).to be_truthy
      end
    end
  end
end
