module DnsimpleStubs
  BASE_URL = "https://api.dnsimple.com/v1"

  def stub_successful_cname_registration(app_name, subdomain)
    stub_cname_registration_request(app_name, subdomain).
      to_return(
        status: 201,
        body: dnsimple_response_body(app_name, subdomain),
      )
  end

  def stub_failed_cname_registration(app_name, subdomain)
    stub_cname_registration_request(app_name, subdomain).
      to_return(
        status: 400,
        body: failed_dnsimple_response_body(subdomain),
      )
  end

  def stub_cname_registration_request(app_name, subdomain)
    stub_request(:post, dnsimple_api_url("/records")).
      with(
        body: dnsimple_request_body(app_name, subdomain),
        headers: dnsimple_headers
    )
  end

  def failed_dnsimple_response_body(subdomain)
    domain = "#{subdomain}.#{ENV.fetch("DNSIMPLE_DOMAIN")}"
    {
      message: "CNAME #{domain} already exists so it was ignored."
    }.to_json
  end

  def dnsimple_api_url(path)
    domain = ENV.fetch("DNSIMPLE_DOMAIN")
    BASE_URL + "/domains/#{domain}" + path
  end

  def dnsimple_request_body(app_name, subdomain)
    to_param = {
      record: {
        content: "#{app_name}.herokuapp.com",
        name: subdomain,
        record_type: "CNAME",
        ttl: 3600
      }
    }.to_param
    CGI.unescape(to_param)
  end

  def dnsimple_response_body(app_name, subdomain)
    {
      record: {
        content: "#{app_name}.herokuapp.com",
        created_at: Time.now.iso8601,
        domain_id: 28,
        id: 172,
        name: subdomain,
        prio: 10,
        record_type: "CNAME",
        ttl: 3600,
        updated_at: Time.now.iso8601,
      }
    }.to_json
  end

  def dnsimple_headers
    {
      "Accept" => "application/json",
      "User-Agent" => "dnsimple-ruby/2.0.0.alpha5",
      "X-Dnsimple-Domain-Token" => ENV.fetch("DNSIMPLE_DOMAIN_TOKEN")
    }
  end
end

RSpec.configure do |config|
  config.include DnsimpleStubs
end
