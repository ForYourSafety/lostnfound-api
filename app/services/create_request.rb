# frozen_string_literal: true

module LostNFound
  # Create a new request for an item by an requester
  class CreateRequest
    # Custom error class for owner not found
    class RequesterNotFound < StandardError
      def message = 'Requester account not found'
    end

    # Custom error class for item not found
    class ItemNotFound < StandardError
      def message = 'Item not found'
    end

    def self.call(requester_id:, item_id:, request_data:)
      requester = Account.first(id: requester_id)
      raise(RequesterNotFound) unless requester

      item = Item.first(id: item_id)
      raise(ItemNotFound) unless item

      request = Request.new
      request.requester = requester
      request.item = item
      request.answer = request_data['answer']

      request.save_changes

      request
    end
  end
end
