require 'renee/version'

module Renee
    # This module is responsible for handling the rendering of
    # JSON, meagre though that task may be.
    module JSON
        # Current version of Renee::JSON
        VERSION = Renee::VERSION

        def json!(*args)
            respond! ::JSON.dump(*args), 200, { 'Content-Type' => 'application/json' }
        end
    end
end
