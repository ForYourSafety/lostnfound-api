# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    route('requests') do |routing|
      @item_route = "#{@api_root}/requests"
      routing.on String do |request_id|
        # GET api/v1/requests/:request_id
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

        # DELETE api/v1/requests/:request_id
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
      end
    end
  end
end
