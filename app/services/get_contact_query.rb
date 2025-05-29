# frozen_string_literal: true

module LostNFound
  # Service to get a contact with permission check
  class GetContactQuery
    # Error for unauthorized access
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that contact'
      end
    end

    # Error for contact not found
    class NotFoundError < StandardError
      def message
        'We could not find that contact'
      end
    end

    def self.call(account:, contact_id:)
      contact = Contact.first(id: contact_id)
      raise NotFoundError unless contact

      item = contact.item
      policy = ContactPolicy.new(account, item)

      raise ForbiddenError unless policy.can_view?

      contact
    end
  end
end
