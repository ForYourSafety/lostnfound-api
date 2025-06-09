# frozen_string_literal: true

module LostNFound
  # Service to get items posted by an account
  class GetAccountItemsQuery
    # All items by an account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access the items of that account'
      end
    end

    def self.call(auth:, username:)
      raise ForbiddenError if auth.nil? || auth.account.nil?
      raise ForbiddenError if auth.account.username != username

      ItemPolicy::AccountScope.new(auth).mine
    end
  end
end
