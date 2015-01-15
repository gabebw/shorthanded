require "rails_helper"

describe "POST /api/apps" do
  context "when it succeeds" do
    it "responds with the URL of the new Heroku app" do
      stub_app_setup(app_name)

      api_post api_apps_path

      expect(json_body["url"]).to eq "https://#{app_name}.herokuapp.com"
    end

    it "responds with 201 Created" do
      stub_app_setup(app_name)

      api_post api_apps_path

      expect(response).to have_http_status(201)
    end
  end

  context "when it fails" do
    it "returns 502 (Bad Response from Upstream Server)" do
      stub_failed_app_setup

      api_post api_apps_path

      expect(response).to have_http_status(502)
    end

    it "returns the Heroku error message" do
      stub_failed_app_setup(
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
    "cheetah"
  end
end
