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

    # Error for forbidden action to add a tag
    class ForbiddenError < StandardError
      def message = 'You are not allowed to add tags to this item'
    end

    # Adds a tag to an item
    def self.call(auth:, item_id:, tag_id:)
      item = Item.first(id: item_id)
      raise(ItemNotFoundError) unless item

      tag = Tag.first(id: tag_id)
      raise(TagNotFoundError) unless tag

      # Ensure the item and tag are not already associated
      raise(ItemAlreadyHasTagError) if item.tags.include?(tag)

      policy = ItemPolicy.new(auth, item, auth.scope)
      raise(ForbiddenError) unless policy.can_add_tag?

      add_tag_to_item(item: item, tag: tag)
    end

    def self.add_tag_to_item(item:, tag:)
      item.add_tag(tag)
    end
  end
end
