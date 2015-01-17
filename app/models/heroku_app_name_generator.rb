# This class generates names for Heroku apps. They have a common prefix so
# they're easy to find in the Heroku console.
#
# Heroku has the following rules about app names:
# * Must be <= 30 characters long
# * Must start with a letter
# * Can only contain lowercase letters, numbers, and dashes
class HerokuAppNameGenerator
  PREFIX = ENV.fetch("HEROKU_APP_NAME_PREFIX")

  def generate
    PREFIX + random_string
  end

  private

  def random_string
    SecureRandom.urlsafe_base64(15).downcase.gsub("_", "-")
  end
end
