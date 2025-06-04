# frozen_string_literal: true

module LostNFound
  # Service to get contact query
  class GetContactQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that contact'
      end
    end

    # Error for cannot find a contact
    class NotFoundError < StandardError
      def message
        'We could not find that contact'
      end
    end

    # Contact for given requestor account
    def self.call(requestor:, contact:)
      raise NotFoundError unless contact

      policy = ContactPolicy.new(requestor, contact)
      raise ForbiddenError unless policy.can_view?

      contact
    end
  end
end
