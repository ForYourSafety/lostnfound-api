# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Contact Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = LostNFound::Account.create(@account_data)
    DATA[:items].each do |item|
      LostNFound::CreateItemForOwner.call(
        owner_id: @account.id,
        item_data: item
      )
    end
    # LostNFound::CreateItemForOwner.call(owner_id: @account.id, item_data: DATA[:item][0])
    # LostNFound::CreateItemForOwner.call(owner_id: @account.id, item_data: DATA[:item][1])

    @wrong_account = LostNFound::Account.create(@wrong_account_data)
    # LostNFound::CreateItemForOwner.call(owner_id: @wrong_account.id, item_data: DATA[:item][2])

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single contact' do
    it 'HAPPY: should be able to get details of a single contact' do
      item = LostNFound::Item.first
      contact_data = DATA[:contacts][1]
      contact = LostNFound::CreateContact.call(
        account: @account,
        item_id: item.id,
        contact_data: contact_data
      )
      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/items/#{item.id}/contacts/#{contact.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']['relationships']['contacts'][0]['data']['attributes']
      _(result['id']).must_equal contact.id
      _(result['contact_type']).must_equal contact_data['contact_type']
      _(result['value']).must_equal contact_data['value']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      contact_data = DATA[:contacts][1]
      item = LostNFound::Item.first
      contact = item.add_contact(contact_data)

      get "/api/v1/contacts/#{contact.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      contact_data = DATA[:contacts][1]
      item = LostNFound::Item.first
      contact = item.add_contact(contact_data)
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/contacts/#{contact.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if contact does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/contacts/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Contacts' do
    before do
      @item = LostNFound::Item.first
      @contact_data = DATA[:contacts][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/items/#{@item.id}/contacts", @contact_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0
      created = JSON.parse(last_response.body)['data']['data']['attributes']
      contact = LostNFound::Contact.first

      _(created['id']).must_equal contact.id
      _(created['value']).must_equal @contact_data['value']
      _(created['contact_type']).must_equal @contact_data['contact_type']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/items/#{@item.id}/contacts", @contact_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/items/#{@item.id}/contacts", @contact_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SECURITY: should not create contacts with mass assignment' do
      bad_data = @contact_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/items/#{@item.id}/contacts", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
