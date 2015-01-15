class Api::V1::AppsController < ApplicationController
  def create
    app_name = "cheetah"
    heroku_json = JSON.parse(deploy(app_name))

    if heroku_json.key?("created_at")
      render json: { url: "https://#{app_name}.herokuapp.com" }, status: 201
    else
      render json: heroku_json, status: 502
    end
  end

  private

  def deploy(app_name)
    begin
      heroku.app_setup.create(
        app: {
          name: app_name,
          personal: true,
        },
        source_blob: {
          url: ENV.fetch("URL_OF_TAR_GZ_TO_DEPLOY"),
        }
      )
    rescue => error
      error.response.body
    end
  end

  def heroku
    @heroku ||= PlatformAPI.connect_oauth(ENV.fetch("HEROKU_OAUTH_TOKEN"))
  end
end
