require "rails_helper"

describe HerokuClient do
  context "#create_and_deploy" do
    context "when successful" do
      it "creates a Heroku application" do
        request_stub = stub_app_setup(app_name)

        client = HerokuClient.new(app_name)
        client.create_and_deploy

        expect(request_stub).to have_been_requested
      end

      it "knows that it was successful" do
        stub_app_setup(app_name)

        client = HerokuClient.new(app_name)
        client.create_and_deploy

        expect(client.creation_succeeded?).to eq true
      end

      context "when unsuccessful" do
        it "can give back the response body" do
          response = {
            id: "foo_bar",
            message: "Foo failed to bar"
          }
          stub_failed_app_setup(app_name, response)

          client = HerokuClient.new(app_name)
          client.create_and_deploy

          expect(client.creation_error_response).to eq response.stringify_keys
        end
      end
    end
  end

  context "#add_domain" do
    it "adds a domain to the app" do
      request = stub_heroku_domain(app_name, domain)
      client = HerokuClient.new(app_name)

      client.add_domain(domain)

      expect(request).to have_been_requested
    end

    it "removes http:// from the domain before adding" do
      request = stub_heroku_domain(app_name, domain)
      client = HerokuClient.new(app_name)

      client.add_domain("http://" + domain)

      expect(request).to have_been_requested
    end

    it "removes https:// from the domain before adding" do
      request = stub_heroku_domain(app_name, domain)
      client = HerokuClient.new(app_name)

      client.add_domain("https://" + domain)

      expect(request).to have_been_requested
    end
  end

  def app_name
    "shorty-abc"
  end

  def domain
    "example.com"
  end
end
