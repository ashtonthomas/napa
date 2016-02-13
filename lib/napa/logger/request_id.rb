# require 'securerandom'
# require 'active_support/core_ext/string/access'

module Napa
  class RequestId < Proc
    X_REQUEST_ID = "X-Request-Id".freeze

    def call(request)
      x_request_id = request.get_header(X_REQUEST_ID)
      request_id = make_request_id(x_request_id)
      binding.pry
    end

    private

    def make_request_id(request_id)
      if request_id.presence
        request_id.gsub(/[^\w\-]/, "".freeze).first(255)
      else
        internal_request_id
      end
    end

    def internal_request_id
      SecureRandom.uuid
    end

  end
end
