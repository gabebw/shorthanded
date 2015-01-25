class Api::V1::AppsController < Api::V1::ApisController
  def create
    heroku_client = create_and_deploy(app_name)

    if heroku_client.creation_succeeded?
      full_domain = register_cname(heroku_client.app_url)
      heroku_client.add_domain(full_domain)
      render json: { url: full_domain }, status: 201
    else
      render json: heroku_client.creation_error_response, status: 502
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
    app_params[:subdomain]
  end

  def app_name
    @app_name ||= HerokuAppNameGenerator.new.generate
  end

  def app_params
    params.require(:app).permit(:subdomain)
  end
end
