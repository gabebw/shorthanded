require "rails_helper"

describe DnsimpleClient do
  context "#register_cname" do
    it "registers a CNAME record for a subdomain to a given URL" do
      stub_dnsimple_request("sub", "asdf.com")
      client = DnsimpleClient.new

      result = client.register_cname("sub", "asdf.com")

      expect(result).to eq "http://sub.#{domain_name}"
    end

    it "strips http:// from the given URL" do
      stub_dnsimple_request("sub", "asdf.com")
      client = DnsimpleClient.new

      result = client.register_cname("sub", "http://asdf.com")

      expect(result).to eq "http://sub.#{domain_name}"
    end

    it "strips https:// from the target URL" do
      stub_dnsimple_request("sub", "asdf.com")
      client = DnsimpleClient.new

      result = client.register_cname("sub", "https://asdf.com")

      expect(result).to eq "http://sub.#{domain_name}"
    end

    it "logs the response body if there is an error" do
      allow(Rails.logger).to receive(:error)
      stub_failed_dnsimple_request("sub", "asdf.com", 403)
      client = DnsimpleClient.new

      result = client.register_cname("sub", "https://asdf.com")

      expect(Rails.logger).to have_received(:error).
        with("[DNSIMPLE CLIENT] " + domain_response("sub", "asdf.com"))
      expect(result).to eq false
    end
  end

  def domain_name
    ENV.fetch("DNSIMPLE_DOMAIN")
  end

  def stub_dnsimple_request(subdomain, url)
    stub_base_request(url, subdomain).
      to_return(status: 200, body: domain_response(subdomain, url))
  end

  def stub_failed_dnsimple_request(subdomain, url, status_code)
    stub_base_request(url, subdomain).
      to_return(status: status_code, body: domain_response(subdomain, url))
  end

  def stub_base_request(url, subdomain)
    params = {
      record: {
        content: url,
        name: subdomain,
        record_type: "CNAME",
        ttl: 3600
      }
    }.to_param

    stub_request(:post, "https://api.dnsimple.com/v1/domains/#{domain_name}/records").
      with(
        body: CGI.unescape(params),
        headers: {
          "Accept" => "application/json",
          "User-Agent" => "dnsimple-ruby/2.0.0.alpha5",
          "X-Dnsimple-Domain-Token" => ENV.fetch("DNSIMPLE_DOMAIN_TOKEN")
        }
      )
  end

  def domain_response(subdomain, url)
    {
      record: {
        content: url,
        created_at: "2013-01-29T14:25:38Z",
        domain_id: 28,
        id: 172,
        name: subdomain,
        prio: 10,
        record_type: "CNAME",
        ttl: 3600,
        updated_at: "2013-01-29T14:25:38Z"
      }
    }.to_json
  end
end
