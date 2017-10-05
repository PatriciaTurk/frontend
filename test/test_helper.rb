require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start 'rails'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/unit'
require 'mocha/mini_test'
require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)
require 'timecop'

require 'slimmer/test_helpers/govuk_components'
require 'govuk-content-schema-test-helpers'

Dir[Rails.root.join('test/support/*.rb')].each { |f| require f }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  include Slimmer::TestHelpers::GovukComponents
  include ContentStoreHelpers

  setup do
    I18n.locale = :en
    stub_shared_component_locales

    GovukAbTesting.configure do |config|
      config.acceptance_test_framework = :active_support
    end

    GovukContentSchemaTestHelpers.configure do |config|
      config.schema_type = 'frontend'
      config.project_root = Rails.root
    end

    stub_request(:post, 'https://ssl.google-analytics.com/collect')
  end

  teardown do
    Timecop.return
  end

  def prevent_implicit_rendering
    # we're not testing view rendering here,
    # so prevent rendering by stubbing out default_render
    @controller.stubs(:default_render)
  end
end
