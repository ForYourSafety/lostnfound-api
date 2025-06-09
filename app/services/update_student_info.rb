# frozen_string_literal: true

module LostNFound
  # update student information for an account
  class UpdateStudentInfo
    # Error raised when the user is not authorized to update the account
    class UnauthorizedError < StandardError
      def message = 'You are not authorized to update this account'
    end

    # Error raised when the provided student information is invalid
    class InvalidDataError < StandardError
      def message = 'Both student_id and name_on_id must be provided'
    end

    def self.call(auth:, username:, student_info:) # rubocop:disable Metrics/MethodLength
      raise UnauthorizedError unless auth
      raise UnauthorizedError unless auth.account.username == username
      raise UnauthorizedError unless auth.scope.can_write?('accounts')

      student_id = student_info[:student_id]
      name_on_id = student_info[:name_on_id]

      raise InvalidDataError unless student_id && name_on_id

      account = Account.first(username: username)
      raise Sequel::NoMatchingRow unless account

      account.update(
        student_id: student_id,
        name_on_id: name_on_id
      )
      account.full_details
    end
  end
end
