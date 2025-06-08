# frozen_string_literal: true

module LostNFound
  # Service to update a request
  # Currently only allows replying to a request
  class UpdateRequest
    # Error for request
    class ForbiddenError < StandardError
      def message
        'You are not allowed to reply to that request'
      end
    end

    # Error for cannot find a request
    class NotFoundError < StandardError
      def message
        'We could not find that request'
      end
    end

    def self.call(auth:, request_id:, merge_patch:)
      request = Request.first(id: request_id)
      raise NotFoundError unless request

      policy = RequestPolicy.new(auth, request)
      raise ForbiddenError unless policy.can_reply?

      set_reply_status(request, merge_patch['status'])
    end

    def self.set_reply_status(request, status)
      status = status.to_sym
      request.status = status
      request.save_changes
      request
    end
  end
end
