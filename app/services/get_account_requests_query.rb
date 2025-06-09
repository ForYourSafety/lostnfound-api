# frozen_string_literal: true

module LostNFound
  # Service to get requests made by an account
  class GetAccountRequestsQuery
    # All requests by an account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access the requests of that account'
      end
    end

    def self.call(auth:, username:)
      raise ForbiddenError if auth.nil? || auth.account.nil?
      raise ForbiddenError if auth.account.username != username

      requests = RequestPolicy::AccountScope.new(auth).mine

      requests.map do |request|
        policy = RequestPolicy.new(auth, request)
        request.to_h.merge(
          policies: policy.summary
        )
      end
    end
  end
end
