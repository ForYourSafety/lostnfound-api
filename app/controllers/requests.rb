# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    route('requests') do |routing|
      @item_route = "#{@api_root}/requests"
      routing.on String do |request_id|
        # GET /api/v1/requests/:request_id
        routing.get do
          item = GetRequestQuery.call(
            auth: @auth,
            request_id: request_id
          )

          { data: item }.to_json
        rescue GetRequestQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetRequestQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND REQUEST ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # DELETE /api/v1/requests/:request_id
        routing.delete do
          deleted_request = DeleteRequest.call(
            auth: @auth,
            request_id: request_id
          )

          response.status = 204
          { message: 'Request deleted', data: deleted_request }.to_json
        rescue DeleteRequest::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue DeleteRequest::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end

        # PATCH /api/v1/requests/:request_id
        routing.patch do
          merge_patch = JSON.parse(routing.body.read)

          routing.halt 400, { message: 'Missing status' }.to_json if merge_patch['status'].nil?

          # Only accepts approved and declined status
          unless %w[approved declined].include?(merge_patch['status'])
            routing.halt 400, { message: 'Invalid status' }.to_json
          end

          updated_request = UpdateRequest.call(
            auth: @auth,
            request_id: request_id,
            merge_patch: merge_patch
          )

          response.status = 200
          { message: 'Request updated', data: updated_request }.to_json
        rescue UpdateRequest::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue UpdateRequest::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{merge_patch.keys}"
          routing.halt 400, { message: 'Illegal Attributes' }.to_json
        rescue StandardError => e
          Api.logger.error "UNKNOWN ERROR: #{e.message}"
          routing.halt 500, { message: 'Unknown server error' }.to_json
        end
      end

      # GET /api/v1/requests
      routing.get do
        requests = GetRequestsQuery.call(
          auth: @auth
        )

        { data: requests }.to_json
      rescue StandardError => e
        puts "GET ACCOUNT REQUESTS ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API Server Error' }.to_json
      end
    end
  end
end
