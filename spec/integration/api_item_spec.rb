# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Item Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting items' do
    describe 'Getting list of items' do
      before do
        @account_data = DATA[:accounts][0]
        account = LostNFound::Account.create(@account_data)
        account.add_item(DATA[:items][0])
        account.add_item(DATA[:items][1])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = LostNFound::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/items'

        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/items'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end

      it 'HAPPY: should be able to get details of a single item' do
        existing_item = DATA[:items][0]
        LostNFound::Item.create(existing_item)
        id = LostNFound::Item.first.id

        get "/api/v1/items/#{id}"
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body

        _(result['data']['attributes']['id']).must_equal id
        _(result['data']['attributes']['name']).must_equal existing_item['name']
      end

      it 'SAD: should return error if unknown item requested' do
        get '/api/v1/items/foobar'

        _(last_response.status).must_equal 404
      end

      it 'SECURITY: should prevent basic SQL injection targeting IDs' do
        LostNFound::Item.create(name: 'New Item', type: 'New Type')
        LostNFound::Item.create(name: 'Newer Item', type: 'Newer Type')
        get 'api/v1/projects/2%20or%20id%3E0'

        # deliberately not reporting error -- don't give attacker information
        _(last_response.status).must_equal 404
        _(last_response.body['data']).must_be_nil
      end

      describe 'Creating New Items' do
        before do
          @req_header = { 'CONTENT_TYPE' => 'application/json' }
          @item_data = DATA[:items][0]
        end

        it 'HAPPY: should be able to create new item' do
          post 'api/v1/items', @item_data.to_json, @req_header

          _(last_response.status).must_equal 201
          _(last_response.headers['Location'].size).must_be :>, 0

          created = JSON.parse(last_response.body)['data']['data']['attributes']
          item = LostNFound::Item.first(id: created['id'])

          _(created['id']).must_equal item.id
          _(created['name']).must_equal @item_data['name']
          _(created['type']).must_equal @item_data['type']
        end

        it 'SECURITY: should not create item with mass assignment' do
          bad_data = @item_data.clone
          bad_data['created_at'] = '1900-01-01'
          post 'api/v1/items', bad_data.to_json, @req_header

          _(last_response.status).must_equal 400
          _(last_response.headers['Location']).must_be_nil
        end
      end
    end
  end
end
