# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeatureFlag do
  let(:key) { :show_records_based_on_location }
  let(:store) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(store)
    ENV.delete("FEATURE_FLAG_SHOW_RECORDS_BASED_ON_LOCATION")
  end

  after { ENV.delete("FEATURE_FLAG_SHOW_RECORDS_BASED_ON_LOCATION") }

  describe ".enabled?" do
    it "returns the supplied default when no override is set" do
      expect(described_class.enabled?(key, default: true)).to be(true)
      expect(described_class.enabled?(key, default: false)).to be(false)
    end

    it "reads from the ENV override when present" do
      ENV["FEATURE_FLAG_SHOW_RECORDS_BASED_ON_LOCATION"] = "false"
      expect(described_class.enabled?(key, default: true)).to be(false)
    end

    it "prefers the Rails.cache value over ENV (runtime toggle)" do
      ENV["FEATURE_FLAG_SHOW_RECORDS_BASED_ON_LOCATION"] = "false"
      described_class.set(key, true)
      expect(described_class.enabled?(key, default: false)).to be(true)
    end

    it "supports clearing the cached value" do
      described_class.set(key, false)
      described_class.clear(key)
      expect(described_class.enabled?(key, default: true)).to be(true)
    end
  end
end
