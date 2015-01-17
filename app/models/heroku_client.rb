class HerokuClient
  def initialize(app_name)
    @app_name = app_name
    @client = PlatformAPI.connect_oauth(ENV.fetch("HEROKU_OAUTH_TOKEN"))
  end

  def create_and_deploy
    begin
      @json_body = client.app_setup.create(
        app: {
          name: app_name,
          personal: true,
        },
        source_blob: {
          url: ENV.fetch("URL_OF_TAR_GZ_TO_DEPLOY"),
        }
      )
    rescue Excon::Errors::ClientError => error
      @json_body = JSON.parse(error.response.body)
    end
  end

  def add_domain(domain)
    domain_without_scheme = domain.sub(%r{https?://}, "")
    client.domain.create(app_name, hostname: domain_without_scheme)
  end

  def creation_succeeded?
    json_body.key?("created_at")
  end

  def app_url
    "https://#{app_name}.herokuapp.com"
  end

  def creation_error_response
    json_body
  end

  private

  attr_reader :app_name, :client, :json_body
end
