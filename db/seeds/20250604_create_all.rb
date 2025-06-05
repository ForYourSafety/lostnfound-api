# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, items, contacts, tags, requests'
    create_accounts
    create_items
    create_contacts
    create_tags
    add_tags_to_items
    create_requests
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS = YAML.load_file("#{DIR}/accounts_seeds.yml")
ITEMS = YAML.load_file("#{DIR}/item_seeds.yml")
CONTACTS = YAML.load_file("#{DIR}/contact_seeds.yml")
TAGS = YAML.load_file("#{DIR}/tags_seeds.yml")
REQUESTS = YAML.load_file("#{DIR}/request_seeds.yml")

RELATIONSHIPS_INFO = YAML.load_file("#{DIR}/seed_relationships.yml")

def scoped_auth(auth_token)
  token = AuthToken.new(auth_token)
  account_data = token.payload['attributes']

  account = LostNFound::Account.find(username: account_data['username'])
  LostNFound::AuthorizedAccount.new(account, token.scope)
end

def create_accounts
  ACCOUNTS.each do |account_data|
    LostNFound::Account.create(account_data)
  end
end

def create_items # rubocop:disable Metrics/MethodLength
  RELATIONSHIPS_INFO.each do |account_info|
    account = LostNFound::Account.find(username: account_info['username'])
    auth_token = AuthToken.create(account)
    auth = scoped_auth(auth_token)

    account_info['items'].each do |item_info|
      item_data = ITEMS.find { |item| item['name'] == item_info['name'] }

      LostNFound::CreateItemForOwner.call(
        auth: auth,
        item_data: item_data
      )
    end
  end
end

def create_contacts # rubocop:disable Metrics/MethodLength
  RELATIONSHIPS_INFO.each do |account_info|
    account = LostNFound::Account.find(username: account_info['username'])
    auth_token = AuthToken.create(account)
    auth = scoped_auth(auth_token)

    account_info['items'].each do |item_info|
      item = LostNFound::Item.find(name: item_info['name'])

      item_info['contact_idxs'].each do |contact_idx|
        contact_data = CONTACTS[contact_idx]

        LostNFound::CreateContactToItem.call(
          auth: auth,
          item_id: item.id,
          contact_data: contact_data
        )
      end
    end
  end
end

def create_tags
  TAGS.each do |tag_data|
    LostNFound::Tag.create(tag_data)
  end
end

def add_tags_to_items
  RELATIONSHIPS_INFO.each do |account_info|
    account = LostNFound::Account.find(username: account_info['username'])
    auth_token = AuthToken.create(account)
    auth = scoped_auth(auth_token)

    account_info['items'].each do |item_info|
      item = LostNFound::Item.find(name: item_info['name'])

      item_info['tag_names'].each do |tag_name|
        tag = LostNFound::Tag.find(name: tag_name)
        LostNFound::AddTagToItem.call(auth: auth, item_id: item.id, tag_id: tag.id)
      end
    end
  end
end

def create_requests # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
  RELATIONSHIPS_INFO.each do |account_info|
    account_info['items'].each do |item_info|
      item = LostNFound::Item.find(name: item_info['name'])

      item_info['requests'].each do |request_info|
        requester = LostNFound::Account.find(username: request_info['requester_name'])
        auth_token = AuthToken.create(requester)
        auth = scoped_auth(auth_token)

        request_data = REQUESTS[request_info['request_idx']]
        status = request_data.delete('status')

        request = LostNFound::CreateRequestToItem.call(
          auth: auth,
          item_id: item.id,
          request_data: request_data
        )

        # Update the request status if provided in the request data
        request.status = status.to_sym
        request.save_changes
      end
    end
  end
end
