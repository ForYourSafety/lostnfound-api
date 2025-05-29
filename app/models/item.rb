# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # model for lost items
  class Item < Sequel::Model
    one_to_many :contacts
    many_to_one :creator, class: 'LostNFound::Account', key: :created_by
    many_to_many :tags, class: 'LostNFound::Tag', join_table: :items_tags

    plugin :uuid, field: :id

    plugin :enum
    enum :type, lost: 0, found: 1

    plugin :association_dependencies, contacts: :destroy, tags: :nullify
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :type, :name, :description, :location, :person_info

    def to_h # rubocop:disable Metrics/MethodLength
      {
        type: 'item',
        attributes: {
          id:,
          type:,
          name:,
          description:,
          location:,
          person_info:,
          created_by:,
          resolved:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          creator:,
          contacts:,
          tags:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
