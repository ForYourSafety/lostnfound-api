# frozen_string_literal: true

require_relative 'app'

module LostNFound
  # Web controller for LostNFound API - contacts
  class Api < Roda
    route('contacts') do |routing|
      unless @auth_account # rubocop:disable Style/IfUnlessModifier
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @contact_route = "#{@api_root}/contacts"

      # GET /api/v1/contacts/[contact_id]
      routing.on String do |contact_id|
        @req_contact = Contact.first(id: contact_id)

        routing.get do
          contact = GetContactQuery.call(
            account: @auth_account, contact_id: contact_id
          )

          { data: contact }.to_json
        rescue GetContactQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetContactQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end
    end
  end
end
