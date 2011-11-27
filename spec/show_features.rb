require 'cuukie'
require 'rack/test'

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

describe 'The Cuukie server' do
  def app
    Sinatra::Application
  end

  it "shows a home page" do
    get '/'
    last_response.should be_ok
    last_response.body.should match '<h1>Cucumber Features</h1>'
    last_response.body.should match '<title>Cuukie</title>'
  end
  
  it "cleans up all features at the beginning of a run" do
    post '/feature_name', {'name' => 'Create User'}.to_json
    post '/before_features'

    get '/'
    last_response.body.should_not match 'Create User'
  end

  it "shows multiple features" do
    post '/feature_name', {'keyword' => 'Feature', 'name' => 'Create User'}.to_json
    post '/feature_name', {'keyword' => 'Feature', 'name' => 'Delete User'}.to_json

    get '/'
    last_response.body.should match 'Feature: Create User'
    last_response.body.should match 'Feature: Delete User'
  end

  it "shows the names and keywords of features" do
    post '/feature_name', {'keyword' => 'Use Case', 'name' => 'Create User'}.to_json

    get '/'
    last_response.body.should match 'Use Case: Create User'
  end
  
  it "runs Cucumber" do
    system "cucumber --format Cuukie::Formatter --require lib/formatter"
  end
end
