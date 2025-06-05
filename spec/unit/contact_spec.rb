# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Contact Databse Model' do
  before do
    wipe_database

    owner = LostNFound::Account.create(DATA[:accounts][0])
    owner.save_changes

    DATA[:items].each do |item|
      LostNFound::CreateItemForOwner.add_item_for_owner(
        owner: owner,
        item_data: item
      )
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    item = LostNFound::Item.first
    contact_data = DATA[:contacts][1].clone
    new_contact = LostNFound::CreateContactToItem.add_item_contact(
      item: item,
      contact_data: contact_data
    )

    contact = LostNFound::Contact.find(id: new_contact.id)
    _(contact.contact_type).must_equal contact_data['contact_type'].to_sym
    _(contact.value).must_equal contact_data['value']
  end

  it 'SECURITY: should not use deterministic integers' do
    item = LostNFound::Item.first
    new_contact = LostNFound::CreateContactToItem.add_item_contact(
      item: item,
      contact_data: DATA[:contacts][1]
    )

    _(new_contact.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    item = LostNFound::Item.first
    new_contact = LostNFound::CreateContactToItem.add_item_contact(
      item: item,
      contact_data: DATA[:contacts][1]
    )
    stored_contact = app.DB[:contacts].first

    _(stored_contact[:value_secure]).wont_equal new_contact.value
  end
end
