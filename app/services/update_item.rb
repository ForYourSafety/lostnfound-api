# frozen_string_literal: true

module LostNFound
  # Service to update a request
  class UpdateItem
    # Error for item
    class ForbiddenError < StandardError
      def message
        'You are not allowed to update that item'
      end
    end

    # Error for cannot find an item
    class NotFoundError < StandardError
      def message
        'We could not find that item'
      end
    end

    def self.update(auth:, item_id:, new_data:, new_images:) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      raise ForbiddenError unless auth
      raise ForbiddenError unless auth.scope.can_write?('items')

      item = Item.first(id: item_id)
      raise NotFoundError unless item

      policy = ItemPolicy.new(auth, item)
      raise ForbiddenError unless policy.can_edit?

      # Validate image data first
      new_images.each { |image| CreateItemForOwner.validate_mime_type(image) }

      tag_ids = new_data.delete('tag_ids') || []
      contacts = new_data.delete('contacts') || []

      updated_images = new_data.delete('existing_images') || []
      current_images = item.image_keys.split(',')

      delete_image_keys = current_images - updated_images

      update_item(item: item, item_data: new_data)

      update_tags(auth: auth, item: item, tag_ids: tag_ids)
      update_contacts(item: item, contacts: contacts)

      # Upload new images
      new_image_keys = new_images.map { |image| CreateItemForOwner.upload_image(image) }

      # Delete old images
      delete_image(delete_image_keys) if delete_image_keys.any?

      item.image_keys = (current_images - delete_image_keys + new_image_keys).join(',')

      item.save_changes

      item
    end

    def self.resolve(auth:, item_id:, resolved: true)
      item = Item.first(id: item_id)
      raise NotFoundError unless item

      policy = ItemPolicy.new(auth, item)
      raise ForbiddenError unless policy.can_resolve?

      set_resolved(item, resolved)
    end

    def self.set_resolved(item, resolved)
      item.resolved = resolved
      item.save_changes
      item
    end

    def self.update_tags(auth:, item:, tag_ids:)
      # Remove existing tags
      item.remove_all_tags

      # Add new tags
      tag_ids.each do |tag_id|
        AddTagToItem.call(
          auth: auth,
          item_id: item.id,
          tag_id: tag_id
        )
      end
    end

    def self.update_contacts(item:, contacts:)
      # Remove existing contacts
      item.contacts.each(&:destroy)

      # Add new contacts
      contacts.each do |contact_data|
        CreateContactToItem.add_item_contact(
          item: item,
          contact_data: contact_data
        )
      end
    end

    def self.delete_image(delete_image_keys)
      delete_image_keys.each do |image_key|
        S3Storage.delete(object_key: image_key)
      end
    end

    def self.update_item(item:, item_data:)
      new_item = item_data.clone
      new_item['type'] = new_item['type'].to_sym # Convert string to enum
      item.update(new_item)
    end
  end
end
