# frozen_string_literal: true

module LostNFound
  # If an account can view, edit, or delete itself
  class GetAccountQuery
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that item'
      end
    end

    def self.call(auth:, username:)
      account = Account.first(username: username)

      policy = AccountPolicy.new(auth, account)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
