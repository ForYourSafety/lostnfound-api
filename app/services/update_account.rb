# frozen_string_literal: true

module LostNFound
  # update account information
  class UpdateAccount
    # Error raised when the user is not authorized to update the account
    class UnauthorizedError < StandardError
      def message = 'You are not authorized to update this account'
    end

    # Error raised when the provided data for account update is invalid
    class InvalidDataError < StandardError
      def message = 'Invalid data provided for account update'
    end

    def self.call(auth:, username:, account_info:)
      raise UnauthorizedError unless auth
      raise UnauthorizedError unless auth.account.username == username
      raise UnauthorizedError unless auth.scope.can_write?('accounts')

      allowed_columns = %i[password student_id name_on_id].freeze
      raise InvalidDataError unless (account_info.keys - allowed_columns).empty?
      raise InvalidDataError if account_info[:password] && account_info[:password].empty?

      account = auth.account
      account.update(account_info)
      account.save_changes
      account
    end
  end
end
