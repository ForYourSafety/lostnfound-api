# frozen_string_literal: true

module LostNFound
  # delete request
  class DeleteRequest
    # Error for request
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete that request'
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
      raise ForbiddenError unless policy.can_delete?

      request.destroy
      request
    end
  end
end
