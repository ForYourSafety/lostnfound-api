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

ACCOUNT_ITEMS_INFO = YAML.load_file("#{DIR}/account_items.yml")
ITEM_CONTACTS_INFO = YAML.load_file("#{DIR}/item_contacts.yml")
ITEM_TAGS_INFO = YAML.load_file("#{DIR}/item_tags.yml")
ITEM_REQUESTS_INFO = YAML.load_file("#{DIR}/item_requests.yml")

def create_accounts
  ACCOUNTS.each do |account_data|
    LostNFound::Account.create(account_data)
  end
end

def create_items
  ACCOUNT_ITEMS_INFO.each do |account_item_info|
    account = LostNFound::Account.find(username: account_item_info['username'])

    account_item_info['items'].each do |item_name|
      item_data = ITEMS.find { |item| item['name'] == item_name }

      LostNFound::CreateItemForOwner.call(
        owner_id: account.id,
        item_data: item_data
      )
    end
  end
end

def create_contacts
  ITEM_CONTACTS_INFO.each do |item_contact_info|
    item = LostNFound::Item.first(name: item_contact_info['item_name'])

    item_contact_info['contact_idxs'].each do |contact_idx|
      contact_data = CONTACTS[contact_idx]

      LostNFound::CreateContactForItem.call(
        item_id: item.id,
        contact_data: contact_data
      )
    end
  end
end

def create_tags
  TAGS.each do |tag_data|
    LostNFound::Tag.create(tag_data)
  end
end

def add_tags_to_items
  ITEM_TAGS_INFO.each do |item_tag_info|
    item = LostNFound::Item.first(name: item_tag_info['item_name'])

    item_tag_info['tag_names'].each do |tag_name|
      tag = LostNFound::Tag.first(name: tag_name)
      item.add_tag(tag)
    end
  end
end

def create_requests # rubocop:disable Metrics/MethodLength
  ITEM_REQUESTS_INFO.each do |item_request_info|
    item = LostNFound::Item.first(name: item_request_info['item_name'])

    item_request_info['requests'].each do |request_info|
      requester = LostNFound::Account.first(username: request_info['requester_name'])
      request_data = REQUESTS[request_info['request_idx']]

      request = LostNFound::CreateRequest.call(
        requester_id: requester.id,
        item_id: item.id,
        request_data: request_data
      )

      # Update the request status if provided in the request data
      request.status = request_data['status'].to_sym
      request.save_changes
    end
  end
end
