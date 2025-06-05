# frozen_string_literal: true

module LostNFound
  # get item query
  class GetItemQuery
    # Error for item
    class ForbiddenError < StandardError
      def message
        'You are not allowed to edit or delete that item'
      end
    end

    # Error for cannot find a item
    class NotFoundError < StandardError
      def message
        'We could not find that item'
      end
    end

    def self.call(auth:, item_id:)
      item = Item.first(id: item_id)
      raise NotFoundError unless item

      policy = ItemPolicy.new(auth, item)
      raise ForbiddenError unless policy.can_view?

      item.full_details.merge(policies: policy.summary)
    end
  end
end
