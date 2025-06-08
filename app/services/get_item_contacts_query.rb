# frozen_string_literal: true

module LostNFound
  # Service to get contact query
  class GetItemContactsQuery
    # Error for contact not allowed to be accessed
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access contacts'
      end
    end

    # All contacts for an item
    def self.call(auth:, item:)
      policy = ItemPolicy.new(auth, item, auth.scope)
      raise ForbiddenError unless policy.can_view_contacts?

      item.contacts.map(&:to_h)
    end
  end
end
