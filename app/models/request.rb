# frozen_string_literal: true

require 'sequel'
require 'json'

module LostNFound
  # models a request for an item
  class Request < Sequel::Model
    many_to_one :item, key: :item_id
    many_to_one :requester, class: 'LostNFound::Account', key: :requester_id

    plugin :uuid, field: :id

    plugin :enum
    enum :status, unanswered: 0, approved: 1, declined: 2

    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :message

    def to_h # rubocop:disable Metrics/MethodLength
      {
        type: 'request',
        attributes: {
          id:,
          item_id:,
          requester_id:,
          message:,
          status:,
          created_at:
        },
        relationships: {
          item: item&.summary
        }
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
