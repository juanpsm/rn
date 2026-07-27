require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  # Casi toda la app está detrás de `authenticate_user!`.
  include Devise::Test::IntegrationHelpers
end
