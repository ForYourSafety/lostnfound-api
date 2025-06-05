# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # models a contact
  class Contact < Sequel::Model
    many_to_one :item
    plugin :uuid, field: :id

    plugin :enum
    enum :contact_type, other: 0, email: 1, phone: 2, address: 3, facebook: 4, twitter: 5, instagram: 6, whatsapp: 7,
                        telegram: 8, line: 9, signal: 10, wechat: 11, discord: 12

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :item_id, :contact_type, :value

    def value
      SecureDB.decrypt(value_secure)
    end

    def value=(value)
      self.value_secure = SecureDB.encrypt(value)
    end

    def to_h
      {
        type: 'contact',
        attributes: {
          id:,
          item_id:,
          contact_type:,
          value:
        }
      }
    end

    def to_json(options = {})
      JSON(
        to_h, options
      )
    end
  end
end
