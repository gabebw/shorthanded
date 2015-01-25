require "rails_helper"

describe DnsimpleClient do
  context "#register_cname" do
    it "registers a CNAME record for a subdomain to a given URL" do
      request_stub = stub_successful_cname_registration("sub", "asdf.com")
      client = DnsimpleClient.new

      client.register_cname("sub", "asdf.com")

      expect(request_stub).to have_been_requested
    end

    it "strips http:// from the given URL" do
      request_stub = stub_successful_cname_registration("sub", "asdf.com")
      client = DnsimpleClient.new

      client.register_cname("sub", "http://asdf.com")

      expect(request_stub).to have_been_requested
    end

    it "strips https:// from the target URL" do
      request_stub = stub_successful_cname_registration("sub", "asdf.com")
      client = DnsimpleClient.new

      client.register_cname("sub", "https://asdf.com")

      expect(request_stub).to have_been_requested
    end

    it "logs the response body if there is an error" do
      allow(Rails.logger).to receive(:error)
      stub_failed_cname_registration("sub", "asdf.com", "oops")
      client = DnsimpleClient.new

      client.register_cname("sub", "https://asdf.com")

      expect(Rails.logger).to have_received(:error).
        with(/\A\[DNSIMPLE CLIENT\] /)
    end
  end

  context "#cname_registration_succeeded?" do
    it "is true when the registration succeeds" do
      stub_successful_cname_registration("sub", "asdf.com")
      client = DnsimpleClient.new

      client.register_cname("sub", "https://asdf.com")

      expect(client.cname_registration_succeeded?).to eq true
    end

    it "is false when the registration succeeds" do
      stub_failed_cname_registration("sub", "asdf.com")
      client = DnsimpleClient.new

      client.register_cname("sub", "https://asdf.com")

      expect(client.cname_registration_succeeded?).to eq false
    end
  end

  context "#creation_error_response" do
    it "is the full JSON body returned from DNSimple on error" do
      stub_failed_cname_registration("sub", "asdf.com", "oops")
      client = DnsimpleClient.new

      client.register_cname("sub", "https://asdf.com")

      expect(client.creation_error_response).to eq("message" => "oops")
    end
  end
end
