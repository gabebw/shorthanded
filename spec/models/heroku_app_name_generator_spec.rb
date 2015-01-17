require "rails_helper"

describe HerokuAppNameGenerator do
  context "#generate" do
    it "prefixes the name with 'shorty-'" do
      name = HerokuAppNameGenerator.new.generate

      expect(name).to start_with "shorty-"
    end

    it "adds a short random string to the end" do
      base64 = "uwm8hsgpzju"
      stub_secure_random(base64)

      name = HerokuAppNameGenerator.new.generate

      expect(name).to end_with base64
    end

    it "generates a name <= 30 characters long" do
      name = HerokuAppNameGenerator.new.generate

      expect(name.size).to be <= 30
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
    allow(SecureRandom).to receive(:urlsafe_base64).with(15).and_return(base64)
  end
end
