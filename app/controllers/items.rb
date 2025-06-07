# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    route('items') do |routing|
      @item_route = "#{@api_root}/items"
      routing.on String do |item_id|
        routing.on 'contacts' do
          @contacts_route = "#{@api_root}/items/#{item_id}/contacts"

          # GET /api/v1/items/:item_id/contacts
          routing.get do
            item = Item.first(id: item_id)
            routing.halt 404, { message: 'Item not found' }.to_json unless item

            contacts = GetItemContactsQuery.call(
              auth: @auth,
              item: item
            )

            { data: contacts }.to_json
          rescue GetItemContactsQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end

          # POST /api/v1/items/:item_id/contacts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            item = Item.first(id: item_id)

            routing.halt 404, { message: 'Item not found' }.to_json unless item

            new_contact = CreateContactToItem.call(
              auth: @auth,
              item_id: item.id,
              contact_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@contacts_route}/#{new_contact.id}"
            { message: 'Contact saved', data: new_contact }.to_json
          rescue CreateContactToItem::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateContactToItem::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end

        # GET api/v1/items/:item_id
        routing.get do
          item = GetItemQuery.call(
            auth: @auth,
            item_id: item_id
          )

          { data: item }.to_json
        rescue GetItemQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetItemQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND ITEM ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end

      routing.is do
        # GET /api/v1/items
        routing.get do
          items = ItemPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: items)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any items' }.to_json
        end

        # POST /api/v1/items
        routing.post do
          json_data = if request.content_type.start_with?('multipart/form-data')
                        routing.params.delete('data')
                      else
                        routing.body.read
                      end
          new_data = JSON.parse(json_data)

          images = routing.params.delete('images') || []

          new_item = CreateItemForOwner.call(
            auth: @auth,
            item_data: new_data,
            images: images
          )

          response.status = 201
          response['Location'] = "#{@item_route}/#{new_item.id}"
          { message: 'Item saved', data: new_item }.to_json
        rescue CreateItemForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue CreateItemForOwner::InvalidImageError => e
          routing.halt 400, { message: e.message }.to_json
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
