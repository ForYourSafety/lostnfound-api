# frozen_string_literal: true

module LostNFound
  # Service to update a request
  class UpdateItem
    # Error for item
    class ForbiddenError < StandardError
      def message
        'You are not allowed to update that item'
      end
    end

    # Error for cannot find an item
    class NotFoundError < StandardError
      def message
        'We could not find that item'
      end
    end

    def self.resolve(auth:, item_id:, resolved: true)
      item = Item.first(id: item_id)
      raise NotFoundError unless item

      policy = ItemPolicy.new(auth, item)
      raise ForbiddenError unless policy.can_resolve?

      set_resolved(item, resolved)
    end

    def self.set_resolved(item, resolved)
      item.resolved = resolved
      item.save_changes
      item
    end
  end
end
