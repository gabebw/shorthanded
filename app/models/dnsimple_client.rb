class DnsimpleClient
  def initialize
    @client = Dnsimple::Client.new(
      domain_api_token: ENV.fetch("DNSIMPLE_DOMAIN_TOKEN")
    )
  end

  attr_reader :full_domain

  def register_cname(subdomain, url)
    record_attributes = {
      content: url.sub(%r{https?://}, ""),
      name: subdomain,
      record_type: "CNAME",
      ttl: 3600,
    }

    begin
      client.domains.create_record(domain_name, record_attributes)
      @succeeded = true
      @full_domain = "http://#{subdomain}.#{domain_name}"
    rescue Dnsimple::RequestError => error
      Rails.logger.error("[DNSIMPLE CLIENT] " + error.response.body)
      @error_response = JSON.parse(error.response.body)
      @succeeded = false
    end
  end

  def creation_error_response
    @error_response
  end

  def cname_registration_succeeded?
    @succeeded
  end

  private

  def domain_name
    ENV.fetch("DNSIMPLE_DOMAIN")
  end

  attr_reader :client
end
