require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'features/cassettes'
  c.hook_into :webmock
  c.ignore_request do |req|
    # Don't mock the call that Poltergeist polls while waiting for
    # Phantomjs to load (http://localhost:<random port>/__identify__)
    req.uri =~ %r{/__identify__$}
  end
  c.filter_sensitive_data('<GOOGLE_API_KEY>') { ENV['GOOGLE_API_KEY'] }
  c.filter_sensitive_data('<GOOGLE_API_CX>') { ENV['GOOGLE_API_CX'] }
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end
