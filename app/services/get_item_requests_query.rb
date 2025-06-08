# frozen_string_literal: true

module LostNFound
  # Service to get requests of an item
  class GetItemRequestsQuery
    # All requests for an item
    def self.call(auth:, item:)
      requests = RequestPolicy::AccountItemScope.new(auth, item).viewable

      requests.map do |request|
        policy = RequestPolicy.new(auth, request)
        request.to_h.merge(
          policies: policy.summary
        )
      end
    end
  end
end
