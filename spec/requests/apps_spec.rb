require "rails_helper"

describe "POST /api/apps" do
  context "when it succeeds" do
    it "responds with the URL of the new Heroku app" do
      stub_dnsimple_client
      stub_heroku(app_name)

      api_post api_apps_path

      expect(json_body["url"]).to eq(
        "http://#{subdomain}.#{ENV.fetch("DNSIMPLE_DOMAIN")}"
      )
    end

    it "responds with 201 Created" do
      stub_heroku(app_name)
      stub_dnsimple_client

      api_post api_apps_path

      expect(response).to have_http_status(201)
    end
  end

  context "when Heroku fails" do
    it "returns 502 (Bad Response from Upstream Server)" do
      stub_failed_app_setup(app_name)

      api_post api_apps_path

      expect(response).to have_http_status(502)
    end

    it "returns the Heroku error message" do
      stub_failed_app_setup(
        app_name,
        id: "foo_bar",
        message: "Foo failed to bar"
      )

      api_post api_apps_path

      expect(json_body["id"]).to eq "foo_bar"
      expect(json_body["message"]).to eq "Foo failed to bar"
    end
  end

  def api_post(path)
    post path, {}.to_json, headers
  end

  def json_body
    @json_body ||= JSON.parse(response.body)
  end

  def headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/vnd.shorthanded+json; version=1"
    }
  end

  def app_name
    @app_name ||= stub_app_name("abcdef-1234")
  end

  def stub_heroku(app_name)
    stub_app_setup(app_name)
    stub_heroku_domain(app_name, domain_for_heroku)
  end

  def stub_dnsimple_client
    client = double("DnsimpleClient")
    allow(client).to receive(:register_cname).with(
      subdomain,
      "https://#{app_name}.herokuapp.com"
    ).and_return("http://#{subdomain}.#{ENV.fetch("DNSIMPLE_DOMAIN")}")
    allow(DnsimpleClient).to receive(:new).and_return(client)
  end

  def subdomain
    @subdomain ||= stub_subdomain("secret-pine")
  end

  def domain_for_heroku
    "#{subdomain}.#{ENV.fetch("DNSIMPLE_DOMAIN")}"
  end

  def stub_subdomain(name)
    generator = double("SubdomainNameGenerator")
    allow(generator).to receive(:generate).and_return(name)
    allow(SubdomainNameGenerator).to receive(:new).and_return(generator)
    name
  end

  def stub_app_name(id)
    name = HerokuAppNameGenerator::PREFIX + "-#{id}"
    generator = double("app name generator", generate: name)
    allow(HerokuAppNameGenerator).to receive(:new).and_return(generator)
    name
  end
end
