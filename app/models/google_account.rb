# frozen_string_literal: true

module LostNFound
  # Maps Google account details to attributes
  class GoogleAccount
    def initialize(go_account)
      @go_account = go_account
    end

    def username
      "#{@go_account['login']}@google"
    end

    def email
      @go_account['email']
    end
  end
end
