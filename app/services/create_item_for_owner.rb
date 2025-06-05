# frozen_string_literal: true

module LostNFound
  # Create an new item for an owner
  class CreateItemForOwner
    # Custom error class for cannot create item
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create items'
      end
    end

    def self.call(auth:, item_data:)
      raise ForbiddenError unless auth
      raise ForbiddenError unless auth.scope.can_write?('items')

      add_item_for_owner(owner: auth.account, item_data: item_data)
    end

    def self.add_item_for_owner(owner:, item_data:)
      new_item = item_data.clone
      new_item['type'] = new_item['type'].to_sym # Convert string to enum
      owner.add_item(new_item)
    end
  end
end
