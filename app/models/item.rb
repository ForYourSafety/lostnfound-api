# frozen_string_literal: true

require 'json'
require 'sequel'

module LostNFound
  # model for lost items
  class Item < Sequel::Model
    one_to_many :contacts
    one_to_many :requests, class: 'LostNFound::Request', key: :item_id
    many_to_one :creator, class: 'LostNFound::Account', key: :created_by
    many_to_many :tags, class: 'LostNFound::Tag', join_table: :items_tags

    plugin :uuid, field: :id

    plugin :enum
    enum :type, lost: 0, found: 1

    plugin :association_dependencies, contacts: :destroy, tags: :nullify, requests: :destroy
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :type, :name, :description, :location, :time, :challenge_question

    def to_h # rubocop:disable Metrics/MethodLength
      {
        type: 'item',
        attributes: {
          id:,
          type:,
          name:,
          description:,
          location:,
          challenge_question:,
          image_keys:,
          created_by:,
          time:,
          resolved:
        },
        relationships: {
          tags:
        }
      }
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        type: 'item',
        attributes: {
          id:,
          type:,
          name:,
          challenge_question:,
          created_by:,
          resolved:
        }
      }
    end

    def full_details
      to_h
    end

    def full_details_with_contacts
      full_details.merge(
        relationships: {
          tags:,
          contacts:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
