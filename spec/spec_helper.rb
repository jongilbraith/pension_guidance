ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rspec/rails'

require 'vcr'

require_relative '../features/support/poltergeist'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.extend GroupHelpers

  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  config.profile_examples = 10

  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  # Reset the locale after each example to ensure
  # all tests start with the expected default locale.
  config.after(:each) do
    I18n.locale = :en
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.configure_rspec_metadata!
  config.hook_into :webmock

  config.ignore_request do |request|
    # Don't mock the call that Poltergeist polls while waiting for
    # PhantomJS to load (http://localhost:<random port>/__identify__)
    request.uri =~ %r{/__identify__$}
  end
end
