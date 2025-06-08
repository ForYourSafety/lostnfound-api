# frozen_string_literal: true

module LostNFound
  # delete item
  class DeleteItem
    # Error for item
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete that item'
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
      raise ForbiddenError unless policy.can_delete?

      item.destroy
      item
    end
  end
end
