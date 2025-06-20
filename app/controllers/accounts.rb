# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    route('accounts') do |routing|
      @account_route = "#{@api_root}/accounts"

      routing.on String do |username|
        routing.on 'requests' do
          @requests_route = "#{@account_route}/#{username}/requests"
          # GET api/v1/accounts/[username]/requests
          # Request made by an account
          routing.get do
            requests = GetAccountRequestsQuery.call(
              auth: @auth,
              username: username
            )

            { data: requests }.to_json
          rescue GetAccountRequestsQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError => e
            puts "GET ACCOUNT REQUESTS ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API Server Error' }.to_json
          end
        end

        routing.on 'items' do
          @items_route = "#{@account_route}/#{username}/items"
          # GET api/v1/accounts/[username]/items
          # Items posted by an account
          routing.get do
            items = GetAccountItemsQuery.call(
              auth: @auth,
              username: username
            )

            { data: items }.to_json
          rescue GetAccountItemsQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError => e
            puts "GET ACCOUNT ITEMS ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API Server Error' }.to_json
          end
        end

        # GET api/v1/accounts/[username]
        routing.get do
          auth = AuthorizeAccount.call(
            auth: @auth, username: username,
            auth_scope: AuthScope::READ_ONLY
          )

          { data: auth }.to_json
        rescue AuthorizeAccount::ForbiddenError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end

        # POST api/v1/accounts/[username]
        routing.put do
          request_data = HttpRequest.new(routing).body_data
          updated_account = UpdateAccount.call(
            auth: @auth, username: username,
            account_info: request_data
          )

          response.status = 200
          { message: 'Student info updated', data: updated_account }.to_json
        rescue UpdateAccount::UnauthorizedError => e
          routing.halt 403, { message: e.message }.to_json
        rescue UpdateAccount::InvalidDataError => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "Error updating account: #{e.inspect} #{e.backtrace.join("\n")}"
          routing.halt 500, { message: 'Error updating account' }.to_json
        end
      end

      # POST api/v1/accounts
      routing.post do
        # Verify signature
        request_data = HttpRequest.new(routing).signed_body_data

        new_account = Account.new(request_data)
        raise('Could not save account') unless new_account.save_changes

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account saved', data: new_account }.to_json
      rescue SignedRequest::VerificationError
        routing.halt '403', { message: 'Must sign request' }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT:: #{request_data.keys}"
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError
        Api.logger.error 'Unknown error saving account'
        routing.halt 500, { message: 'Error creating account' }.to_json
      end
    end
  end
end
