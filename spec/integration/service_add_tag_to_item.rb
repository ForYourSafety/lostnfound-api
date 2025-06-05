# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddTagToItem service' do
  before do
    owner = LostNFound::Account.create(DATA[:accounts].first)
    owner.save_changes

    @item = LostNFound::CreateItemForOwner.add_item_for_owner(
      owner: owner,
      item_data: DATA[:items][1]
    )

    @tag = LostNFound::Tag.create(DATA[:tags][0])
    @tag.save_changes
  end

  it 'HAPPY: should be able to add a tag to an item' do
    LostNFound::AddTagToItem.call(item_id: @item.id, tag_id: @tag.id)

    _(@item.tags.count).must_equal 1
    _(@item.tags.first.name).must_equal @tag.name
  end

  it 'HAPPY: should reuse existing tag if already exists' do
    LostNFound::AddTagToItem.call(item_id: @item.id, tag_id: @tag.id)
    LostNFound::AddTagToItem.call(item_id: @item.id, tag_id: @tag.id)

    _(LostNFound::Tag.where(name: @tag.name).count).must_equal 1
    _(@item.tags.first.name).must_equal @tag.name
  end
end
