class Api::V1::AppsController < ApplicationController
  def create
    client = create_and_deploy

    if client.succeeded?
      render json: { url: client.app_url }, status: 201
    else
      render json: client.error_response, status: 502
    end
  end

  private

  def create_and_deploy
    HerokuClient.new(app_name).tap do |client|
      client.create_and_deploy
    end
  end

  def app_name
    "cheetah"
  end
end
