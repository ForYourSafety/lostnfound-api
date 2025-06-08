# frozen_string_literal: true

module LostNFound
  # Service to get requests to an account
  class GetRequestsQuery
    def self.call(auth:)
      requests = RequestPolicy::AccountScope.new(auth).to_me

      requests.map do |request|
        policy = RequestPolicy.new(auth, request)
        request.to_h.merge(
          policies: policy.summary
        )
      end
    end
  end
end
