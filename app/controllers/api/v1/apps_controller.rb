class Api::V1::AppsController < Api::V1::ApisController
  def create
    heroku_client = create_and_deploy(app_name)

    if heroku_client.creation_succeeded?
      dnsimple_client = register_cname(heroku_client.app_url)
      if dnsimple_client.cname_registration_succeeded?
        heroku_client.add_domain(dnsimple_client.full_domain)
        render json: { url: dnsimple_client.full_domain }, status: 201
      else
        render json: dnsimple_client.creation_error_response, status: 502
      end
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
    DnsimpleClient.new.tap do |dnsimple_client|
      dnsimple_client.register_cname(subdomain, url)
    end
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
