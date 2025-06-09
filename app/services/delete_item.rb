# frozen_string_literal: true

module LostNFound
  # delete item
  class DeleteItem
    # Error for item
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete that item'
      end
    end

    # Error for cannot find a item
    class NotFoundError < StandardError
      def message
        'We could not find that item'
      end
    end

    def self.call(auth:, item_id:)
      item = Item.first(id: item_id)
      raise NotFoundError unless item

      policy = ItemPolicy.new(auth, item)
      raise ForbiddenError unless policy.can_delete?

      delete_images(item.image_keys.split(',')) if item.image_keys

      item.destroy
      item
    end

    def self.delete_images(image_keys)
      return if image_keys.nil? || image_keys.empty?

      image_keys.each do |image_key|
        S3Storage.delete(object_key: image_key)
      end
    rescue StandardError => e
      Api.logger.warn("Failed to delete images: #{e.message}")
    end
  end
end
