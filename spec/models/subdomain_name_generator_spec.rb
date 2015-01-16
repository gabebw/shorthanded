require "spec_helper"
require SPEC_ROOT.join("../app/models/subdomain_name_generator")

describe SubdomainNameGenerator do
  context "#generate" do
    it "generates an adjective-noun name" do
      stub_const("SubdomainNameGenerator::ADJECTIVES", ["a"])
      stub_const("SubdomainNameGenerator::NOUNS", ["b"])

      name = SubdomainNameGenerator.new.generate

      expect(name).to eq "a-b"
    end
  end
end
