# frozen_string_literal: true

module LostNFound
  # Create a new request for an item by an requester
  class CreateRequestToItem
    # Custom error class for owner not found
    class RequesterNotFound < StandardError
      def message = 'Requester account not found'
    end

    # Custom error class for item not found
    class ItemNotFound < StandardError
      def message = 'Item not found'
    end

    # Custom error for forbidden action to create a request
    class ForbiddenError < StandardError
      def message = 'You are not allowed to create requests to this item'
    end

    # Creates a new request for an item
    def self.call(auth:, item_id:, request_data:)
      item = Item.first(id: item_id)
      raise(ItemNotFound) unless item

      policy = ItemPolicy.new(auth, item, auth.scope)
      raise(ForbiddenError) unless policy.can_request?

      request = add_request_to_item(requester: auth.account, item: item, request_data: request_data)

      SendItemRequestNotification.new(
        item: item,
        request: request
      ).call

      request
    end

    # Creates a new request for an item by an requester
    def self.add_request_to_item(requester:, item:, request_data:)
      request = Request.new(request_data)
      request.requester = requester
      request.item = item

      request.save_changes
      request
    end
  end
end
