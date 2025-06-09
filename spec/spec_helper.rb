# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  LostNFound::Contact.map(&:destroy)
  LostNFound::Item.map(&:destroy)
  LostNFound::Account.map(&:destroy)
end

def authenticate(account_data)
  LostNFound::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  authenticated_account = authenticate(account_data)

  "Bearer #{authenticated_account[:attributes][:auth_token]}"
end

def authorization(account_data)
  authenticated_account = authenticate(account_data)

  token = AuthToken.new(authenticated_account[:attributes][:auth_token])
  account_data = token.payload['attributes']
  account = LostNFound::Account.first(username: account_data['username'])
  LostNFound::AuthorizedAccount.new(account, token.scope)
end

DATA = {
  accounts: YAML.load_file('db/seeds/accounts_seeds.yml'),
  contacts: YAML.load_file('db/seeds/contact_seeds.yml'),
  items: YAML.load_file('db/seeds/item_seeds.yml')
}.freeze

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load_file('spec/fixtures/github_token_response.yml')
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load_file('spec/fixtures/sso_account.yml')
