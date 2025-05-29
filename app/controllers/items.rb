# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    route('items') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @item_route = "#{@api_root}/items"
      routing.on String do |item_id|
        routing.on 'contacts' do
          @contacts_route = "#{@api_root}/items/#{item_id}/contacts"

          # GET /api/v1/items/:item_id/contacts/:contact_id
          routing.get String do |contact_id|
            result = GetContactQuery.call(
              account: @auth_account,
              contact_id: contact_id
            )
            { data: result }.to_json
          rescue GetContactQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue GetContactQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR (GetContact): #{e.full_message}"
            routing.halt 500, { message: 'Unexpected server error' }.to_json
          end

          # GET /api/v1/items/:item_id/contacts
          routing.get do
            item = Item.first(id: item_id)
            routing.halt 404, { message: 'Item not found' }.to_json unless item
            policy = ContactPolicy.new(@auth_account, item)
            routing.halt 403, { message: 'Not authorized' }.to_json unless policy.can_view?

            { data: item.contacts.map(&:to_h) }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end

          # POST /api/v1/items/:item_id/contacts
          routing.post do
            item = Item.first(id: item_id)
            routing.halt 404, { message: 'Item not found' }.to_json unless item
            policy = ContactPolicy.new(@auth_account, item)
            routing.halt 403, { message: 'Not authorized' }.to_json unless policy.can_edit?

            new_data = JSON.parse(routing.body.read)
            new_contact = CreateContactForItem.call(
              item_id: item.id, contact_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@contacts_route}/#{new_contact.id}"
            { message: 'Contact saved', data: new_contact }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR (GetItem): #{e.full_message}"
            routing.halt 500, { message: 'Unexpected server error' }.to_json
          end
        end

        # GET /api/v1/items/:item_id
        routing.get do
          result = GetItemQuery.call(
            account: @auth_account,
            item_id: item_id
          )
          { data: result }.to_json
        rescue GetItemQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetItemQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR (GetItem): #{e.full_message}"
          routing.halt 500, { message: 'Unexpected server error' }.to_json
        end
      end

      routing.is do
        # GET /api/v1/items
        routing.get do
          items = ItemPolicy::AccountScope.new(@auth_account).viewable
          { data: items.map(&:full_details) }.to_json
        end

        # POST /api/v1/items
        routing.post do
          new_data = JSON.parse(routing.body.read)

          # TODO: temporarily use the first account as the owner
          # this should be replaced with the actual owner
          # once the authentication is implemented
          new_item = CreateItemForOwner.call(
            owner_id: @auth_account['id'],
            item_data: new_data
          )
          response.status = 201
          response['Location'] = "#{@item_route}/#{new_item.id}"
          { message: 'Item saved', data: new_item }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end
    end
  end
end
