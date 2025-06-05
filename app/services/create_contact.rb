# frozen_string_literal: true

module LostNFound
  # Create a new contact for an item
  class CreateContact
    # Error for owner cannot add more contacts
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add contacts'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a contact with those attributes'
      end
    end

    # Custom error class for item not found
    class ItemNotFoundError < StandardError
      def message
        'Item not found'
      end
    end

    def self.call(auth:, item_id:, contact_data:)
      item = Item.first(id: item_id)
      raise(ItemNotFoundError) unless item

      policy = ItemPolicy.new(auth, item)
      raise ForbiddenError unless policy.can_add_contact?

      add_item_contact(item: item, contact_data: contact_data)
    end

    def self.add_item_contact(item:, contact_data:)
      new_data = contact_data.clone
      new_data['contact_type'] = new_data['contact_type'].to_sym # Convert string to enum
      item.add_contact(new_data)
    end
  end
end
