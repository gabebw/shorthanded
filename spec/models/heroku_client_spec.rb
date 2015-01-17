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

        expect(client.succeeded?).to eq true
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

          expect(client.error_response).to eq response.stringify_keys
        end
      end
    end
  end

  def app_name
    "shorty-abc"
  end
end
