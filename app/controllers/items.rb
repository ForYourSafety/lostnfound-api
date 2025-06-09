# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda # rubocop:disable Metrics/ClassLength
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

        routing.on 'requests' do
          @requests_route = "#{@api_root}/items/#{item_id}/requests"

          # GET /api/v1/items/:item_id/requests
          routing.get do
            item = Item.first(id: item_id)
            routing.halt 404, { message: 'Item not found' }.to_json unless item

            requests = GetItemRequestsQuery.call(
              auth: @auth,
              item: item
            )

            { data: requests }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end

          # POST /api/v1/items/:item_id/requests
          routing.post do
            new_data = JSON.parse(routing.body.read)
            item = Item.first(id: item_id)

            routing.halt 404, { message: 'Item not found' }.to_json unless item

            new_request = CreateRequestToItem.call(
              auth: @auth,
              item_id: item.id,
              request_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@requests_route}/#{new_request.id}"
            { message: 'Request saved', data: new_request }.to_json
          rescue CreateRequestToItem::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
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

        # DELETE api/v1/items/:item_id
        routing.delete do
          deleted_item = DeleteItem.call(
            auth: @auth,
            item_id: item_id
          )

          response.status = 204
          { message: 'Item deleted', data: deleted_item }.to_json
        rescue DeleteItem::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue DeleteItem::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end

        # PATCH api/v1/items/:item_id
        routing.patch do
          merge_patch = JSON.parse(routing.body.read)

          routing.halt 400, { message: 'Missing resolved' }.to_json if merge_patch['resolved'].nil?

          # Only accepts resolved
          unless merge_patch.keys.all? { |k| %w[resolved].include?(k) }
            routing.halt 400, { message: 'Invalid attributes' }.to_json
          end

          # Only accepts 1 for resolved
          routing.halt 400, { message: 'Invalid resolved value' }.to_json unless merge_patch['resolved'] == 1

          updated_item = UpdateItem.resolve(
            auth: @auth,
            item_id: item_id,
            resolved: merge_patch['resolved'] == 1
          )

          response.status = 200
          { message: 'Item updated', data: updated_item }.to_json
        rescue UpdateItem::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue UpdateItem::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end

        # PUT api/v1/items/:item_id
        routing.put do
          json_data = if request.content_type == 'application/json'
                        routing.body.read
                      else
                        routing.params.delete('data')
                      end
          new_data = JSON.parse(json_data)

          images = routing.params.delete('images') || []

          new_item = UpdateItem.update(
            auth: @auth,
            item_id: item_id,
            new_data: new_data,
            new_images: images
          )

          response.status = 200
          response['Location'] = "#{@item_route}/#{new_item.id}"
          { message: 'Item saved', data: new_item }.to_json
        rescue UpdateItem::ForbiddenError => e
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

      routing.is do
        # GET /api/v1/items
        routing.get do
          items = ItemPolicy::AccountScope.new(@auth_account).public_view

          JSON.pretty_generate(data: items)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any items' }.to_json
        end

        # POST /api/v1/items
        routing.post do
          json_data = if request.content_type == 'application/json'
                        routing.body.read
                      else
                        routing.params.delete('data')
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
