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

DATA = {
  accounts: YAML.load_file('db/seeds/accounts_seeds.yml'),
  contacts: YAML.load_file('db/seeds/contact_seeds.yml'),
  items: YAML.load_file('db/seeds/item_seeds.yml')
}.freeze
