require "rails_helper"

describe HerokuAppNameGenerator do
  context "#generate" do
    it "prefixes nams with 'shorthanded-'" do
      name = HerokuAppNameGenerator.new.generate

      expect(name).to start_with "shorthanded-"
    end

    it "adds a short random string to the end" do
      base64 = "uwm8hsgpzju"
      stub_secure_random(base64)

      name = HerokuAppNameGenerator.new.generate

      expect(name).to end_with base64
    end

    it "downcases the app name" do
      base64 = "UWm8hsgPzjU"
      stub_secure_random(base64)

      name = HerokuAppNameGenerator.new.generate

      expect(name.downcase).to eq name
    end

    it "replaces underscores with hyphens" do
      base64 = "am_pm"
      stub_secure_random(base64)

      name = HerokuAppNameGenerator.new.generate

      expect(name).to end_with "am-pm"
    end
  end

  def stub_secure_random(base64)
    allow(SecureRandom).to receive(:urlsafe_base64).with(8).and_return(base64)
  end
end
