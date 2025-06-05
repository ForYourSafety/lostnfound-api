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

      item_data = item_data.clone
      item_data['type'] = item_data['type'].to_sym # Convert string to enum
      auth.account.add_item(item_data)
    end
  end
end
