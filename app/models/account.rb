# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative 'password'

module LostNFound
  # models a registered account
  class Account < Sequel::Model
    one_to_many :items, key: :created_by
    one_to_many :requests, key: :requester_id

    plugin :uuid, field: :id

    plugin :association_dependencies, items: :destroy

    plugin :whitelist_security
    set_allowed_columns :username, :password, :email, :student_id, :name_on_id

    plugin :timestamps, update_on_create: true

    def self.create_google_account(google_account)
      create(username: google_account[:username],
             email: google_account[:email])
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      password = LostNFound::Password.from_digest(password_digest)
      password.correct?(try_password)
    end

    def to_h
      {
        type: 'account',
        attributes: {
          id:,
          username:,
          email:
        }
      }
    end

    def full_details
      to_h.merge(
        attributes: {
          student_id:,
          name_on_id:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
