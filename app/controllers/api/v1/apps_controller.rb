class Api::V1::AppsController < ApplicationController
  def create
    heroku_client = create_and_deploy(app_name)

    if heroku_client.succeeded?
      full_domain = register_cname(heroku_client.app_url)
      render json: { url: full_domain }, status: 201
    else
      render json: heroku_client.error_response, status: 502
    end
  end

  private

  def create_and_deploy(app_name)
    HerokuClient.new(app_name).tap do |client|
      client.create_and_deploy
    end
  end

  def register_cname(url)
    dnsimple_client = DnsimpleClient.new
    dnsimple_client.register_cname(subdomain, url)
  end

  def subdomain
    SubdomainNameGenerator.new.generate
  end

  def app_name
    @app_name ||= HerokuAppNameGenerator.new.generate
  end
end
