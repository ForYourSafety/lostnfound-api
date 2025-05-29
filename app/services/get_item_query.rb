# frozen_string_literal: true

module LostNFound
  # Service to get an item with permission check
  class GetItemQuery
    # Error for unauthorized access
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that Item'
      end
    end

    # Error for item not found
    class NotFoundError < StandardError
      def message
        'We could not find that item'
      end
    end

    def self.call(account:, item_id:)
      item = Item.first(id: item_id)
      raise NotFoundError unless item

      policy = ItemPolicy.new(account, item)

      # now is always true, but we keep it for clarity
      raise ForbiddenError unless policy.can_view?

      item.full_details.merge(policies: policy.summary)
    end
  end
end
