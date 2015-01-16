class DnsimpleClient
  def initialize
    @client = Dnsimple::Client.new(
      domain_api_token: ENV.fetch("DNSIMPLE_DOMAIN_TOKEN")
    )
  end

  def register_cname(subdomain, url)
    record_attributes = {
      content: url.sub(%r{https?://}, ""),
      name: subdomain,
      record_type: "CNAME",
      ttl: 3600,
    }

    begin
      client.domains.create_record(domain_name, record_attributes)
      "http://#{subdomain}.#{domain_name}"
    rescue Dnsimple::RequestError => error
      Rails.logger.error("[DNSIMPLE CLIENT] " + error.response.body)
      false
    end
  end

  private

  def domain_name
    ENV.fetch("DNSIMPLE_DOMAIN")
  end

  attr_reader :client
end
