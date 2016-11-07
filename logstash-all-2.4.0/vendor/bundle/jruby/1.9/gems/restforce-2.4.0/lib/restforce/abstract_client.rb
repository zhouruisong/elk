module Restforce
  class AbstractClient
    include Restforce::Concerns::Base
    include Restforce::Concerns::Connection
    include Restforce::Concerns::Authentication
    include Restforce::Concerns::Caching
    include Restforce::Concerns::API
  end
end
