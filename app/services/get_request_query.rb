# frozen_string_literal: true

module LostNFound
  # get request query
  class GetRequestQuery
    # Error for request not allowed to be accessed
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access this request'
      end
    end

    # Error for cannot find a request
    class NotFoundError < StandardError
      def message
        'We could not find that request'
      end
    end

    def self.call(auth:, request_id:)
      request = Request.first(id: request_id)
      raise NotFoundError unless request

      policy = RequestPolicy.new(auth, request)
      raise ForbiddenError unless policy.can_view?

      request_details = request.full_details
      request_details.merge(policies: policy.summary)
    end
  end
end
