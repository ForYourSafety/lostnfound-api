# frozen_string_literal: true

module LostNFound
  # Add a tag to an item
  class AddTagToItem
    # Error for item not found
    class ItemNotFoundError < StandardError
      def message = 'Item not found'
    end

    # Error for tag not found
    class TagNotFoundError < StandardError
      def message = 'Tag not found'
    end

    # Error for item already having the tag
    class ItemAlreadyHasTagError < StandardError
      def message = 'Item already has this tag'
    end

    # Adds a tag to an item
    def self.call(item_id:, tag_id:)
      item = Item.first(id: item_id)
      raise(ItemNotFoundError) unless item

      tag = Tag.first(id: tag_id)
      raise(TagNotFoundError) unless tag

      # Ensure the item and tag are not already associated
      raise(ItemAlreadyHasTagError) if item.tags.include?(tag)

      item.add_tag(tag)
    end
  end
end
