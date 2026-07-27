ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors, with: :threads)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Casi todos los controladores usan `authenticate_user!`, así que los tests de
# integración necesitan el helper `sign_in` de Devise.
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
