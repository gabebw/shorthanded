module HerokuStubs
  BASE_URL = "https://api.heroku.com"

  def stub_heroku_domain(app_name, domain)
    stub_request(:post, api_url("/apps/#{app_name}/domains")).
      with(body: domain_request_body(domain)).
      to_return(
        status: 201,
        body: domain_response_body(domain),
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_app_setup(app_name)
    stub_request(:post, api_url("/app-setups")).
      with(body: request_body(app_name)).
      to_return(
        status: 201,
        body: app_setup_body(app_name),
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_failed_app_setup(app_name, options = {})
    stub_request(:post, api_url("/app-setups")).
      with(body: request_body(app_name)).
      to_return(
        status: 422,
        body: failed_app_setup_body(options),
        headers: { "Content-Type" => "application/json" }
      )
  end

  def app_setup_body(app_name)
    {
      id: "b3586b53-43fe-4253-80da-940eb031345f",
      failure_message: nil,
      status: "pending",
      app: {
        id: "190c99fa-f4ab-4d15-8bdb-279da51ab1a7",
        name: app_name,
      },
      build: {
        id: nil,
        status: nil
      },
      manifest_errors: [],
      postdeploy: {
        output: nil,
        exit_code: nil
      },
      resolved_success_url: nil,
      created_at: "2015-01-16T00:30:20+00:00",
      updated_at: "2015-01-16T00:30:20+00:00"
    }.to_json
  end

  def failed_app_setup_body(options)
    {
      id: options.fetch(:id, "invalid_params"),
      message: options.fetch(:message, "Name is already taken")
    }.to_json
  end

  def request_body(app_name)
    {
      app: {
        name: app_name,
        personal: true,
      },
      source_blob: {
        url: ENV.fetch("URL_OF_TAR_GZ_TO_DEPLOY"),
      }
    }.to_json
  end

  def domain_request_body(domain)
    { hostname: domain }.to_json
  end

  def domain_response_body(domain)
    {
      created_at: "2012-01-01T12:00:00Z",
      hostname: domain,
      id: "01234567-89ab-cdef-0123-456789abcdef",
      updated_at: "2012-01-01T12:00:00Z"
    }.to_json
  end

  def api_url(path)
    BASE_URL + path
  end
end

RSpec.configure do |config|
  config.include HerokuStubs
end
