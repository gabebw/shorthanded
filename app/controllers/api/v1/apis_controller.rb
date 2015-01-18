class Api::V1::ApisController < ApplicationController
  before_action :authorize_app_secret

  private

  def authorize_app_secret
    unless correct_app_secret?
      render nothing: true, status: 404
    end
  end

  def correct_app_secret?
    request.headers["X-App-Secret"] == ENV.fetch("HEADER_SECRET")
  end
end
