module HerokuStubs
  def stub_app_setup(app_name)
    stub_request(:post, "https://api.heroku.com/app-setups").
      with(body: request_body(app_name)).
      to_return(
        status: 201,
        body: app_setup_body(app_name),
        headers: { "Content-Type" => "application/json" }
      )
  end

  def stub_failed_app_setup(options = {})
    stub_request(:post, "https://api.heroku.com/app-setups").
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
end

RSpec.configure do |config|
  config.include HerokuStubs, type: :request
end
