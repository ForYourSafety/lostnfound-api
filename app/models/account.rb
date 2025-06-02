# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative 'password'

module LostNFound
  # models a registered account
  class Account < Sequel::Model
    one_to_many :items, key: :created_by
    one_to_many :requests, key: :requester_id
    one_to_many :account_owner_infos, key: :account_id

    plugin :uuid, field: :id

    plugin :association_dependencies, items: :destroy

    plugin :whitelist_security
    set_allowed_columns :username, :password, :email

    plugin :timestamps, update_on_create: true

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      password = LostNFound::Password.from_digest(password_digest)
      password.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:
          }
        }, options
      )
    end
  end
end
