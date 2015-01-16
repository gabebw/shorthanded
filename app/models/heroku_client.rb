class HerokuClient
  def initialize(app_name)
    @app_name = app_name
    @client = PlatformAPI.connect_oauth(ENV.fetch("HEROKU_OAUTH_TOKEN"))
  end

  def create_and_deploy
    begin
      @body = client.app_setup.create(
        app: {
          name: app_name,
          personal: true,
        },
        source_blob: {
          url: ENV.fetch("URL_OF_TAR_GZ_TO_DEPLOY"),
        }
      )
    rescue Excon::Errors::ClientError => error
      @body = error.response.body
    end
  end

  def succeeded?
    json_body.key?("created_at")
  end

  def app_url
    "https://#{app_name}.herokuapp.com"
  end

  def error_response
    @body
  end

  private

  attr_reader :app_name, :client

  def json_body
    JSON.parse(@body)
  end
end
