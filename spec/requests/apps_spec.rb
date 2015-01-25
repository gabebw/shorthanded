require "rails_helper"

describe "POST /api/apps" do
  context "when it succeeds" do
    it "responds with the URL of the new Heroku app" do
      subdomain = "cool-subdomain"
      stub_dnsimple(app_name, subdomain)
      stub_heroku(app_name, subdomain)

      api_post api_apps_path, subdomain

      expect(json_body["url"]).to eq(
        "http://#{subdomain}.#{ENV.fetch("DNSIMPLE_DOMAIN")}"
      )
    end

    it "responds with 201 Created" do
      subdomain = "cool-subdomain"
      stub_dnsimple(app_name, subdomain)
      stub_heroku(app_name, subdomain)

      api_post api_apps_path, subdomain

      expect(response).to have_http_status(201)
    end
  end

  context "when Heroku fails" do
    it "returns 502 (Bad Response from Upstream Server)" do
      subdomain = "cool-subdomain"
      stub_dnsimple(app_name, subdomain)
      stub_failed_app_setup(app_name)

      api_post api_apps_path, subdomain

      expect(response).to have_http_status(502)
    end

    it "returns the Heroku error message" do
      subdomain = "cool-subdomain"
      stub_dnsimple(app_name, subdomain)
      stub_failed_app_setup(
        app_name,
        id: "foo_bar",
        message: "Foo failed to bar"
      )

      api_post api_apps_path, subdomain

      expect(json_body["id"]).to eq "foo_bar"
      expect(json_body["message"]).to eq "Foo failed to bar"
    end
  end

  context "when DNSimple fails" do
    it "returns 502 (Bad Response from Upstream Server)" do
      subdomain = "cool-subdomain"
      stub_failed_cname_registration(subdomain, "#{app_name}.herokuapp.com")
      stub_heroku(app_name, subdomain)

      api_post api_apps_path, subdomain

      expect(response).to have_http_status(502)
    end

    it "returns the DNSimple response" do
      subdomain = "cool-subdomain"
      stub_failed_cname_registration(
        subdomain,
        "#{app_name}.herokuapp.com",
        "failure"
      )
      stub_heroku(app_name, subdomain)

      api_post api_apps_path, subdomain

      expect(json_body["message"]).to eq "failure"
    end
  end

  def api_post(path, subdomain)
    data = { app: { subdomain: subdomain } }.to_json
    post path, data, headers
  end

  def json_body
    @json_body ||= JSON.parse(response.body)
  end

  def headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/vnd.shorthanded+json; version=1",
      "X-App-Secret" => ENV.fetch("HEADER_SECRET"),
    }
  end

  def app_name
    @app_name ||= stub_app_name("abcdef-1234")
  end

  def stub_dnsimple(app_name, subdomain)
    stub_successful_cname_registration(subdomain, "#{app_name}.herokuapp.com")
  end

  def stub_heroku(app_name, subdomain)
    stub_app_setup(app_name)
    stub_heroku_domain(app_name, domain_for_heroku(subdomain))
  end

  def domain_for_heroku(subdomain)
    "#{subdomain}.#{ENV.fetch("DNSIMPLE_DOMAIN")}"
  end

  def stub_app_name(id)
    name = HerokuAppNameGenerator::PREFIX + "-#{id}"
    generator = double("app name generator", generate: name)
    allow(HerokuAppNameGenerator).to receive(:new).and_return(generator)
    name
  end
end
