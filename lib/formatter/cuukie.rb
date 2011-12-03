require 'rest-client'

module Cuukie
  class Formatter
    def initialize(step_mother, io, options)
    end
 
    def before_features(features)
      RestClient.post 'http://localhost:4569/before_features', ''
    end
    
    def feature_name(keyword, name)
      RestClient.post 'http://localhost:4569/feature_name', {'keyword' => keyword, 'name' => name}.to_json
    end
  end
end
