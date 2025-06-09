# frozen_string_literal: true

require 'securerandom'
require 'mimemagic'

module LostNFound
  # Create an new item for an owner
  class CreateItemForOwner
    # Custom error class for cannot create item
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create items'
      end
    end

    # Custom error class for invalid image type
    class InvalidImageError < StandardError
      def message
        'Invalid image type. Only images such as PNG, JPEG, GIF, WEBP are allowed.'
      end
    end

    def self.call(auth:, item_data:, images: [])
      raise ForbiddenError unless auth
      raise ForbiddenError unless auth.scope.can_write?('items')

      # Validate image data first
      images.each { |image| validate_mime_type(image) }

      tag_ids = item_data.delete('tag_ids') || []
      contacts = item_data.delete('contacts') || []

      owner_name = item_data.delete('owner_name')
      owner_student_id = item_data.delete('owner_student_id')

      item = add_item_for_owner(owner: auth.account, item_data: item_data)

      handle_tags(auth: auth, item: item, tag_ids: tag_ids)
      handle_contacts(auth: auth, item: item, contacts: contacts)

      image_keys = images.map { |image| upload_image(image) }
      item.image_keys = image_keys.join(',') if image_keys.any?
      item.save_changes

      SendOwnerNotification.new(
        item: item,
        owner_name: owner_name,
        owner_student_id: owner_student_id
      ).call

      item
    end

    def self.validate_mime_type(image)
      image[:mime_type] = MimeMagic.by_magic(image[:tempfile])
      raise InvalidImageError unless image[:mime_type]
      raise InvalidImageError unless image[:mime_type].image?
    end

    def self.upload_image(image)
      uuid = SecureRandom.uuid
      S3Storage.upload(
        object_key: uuid,
        contents: image[:tempfile],
        content_type: image[:mime_type].to_s
      )

      uuid
    end

    def self.handle_tags(auth:, item:, tag_ids:)
      return unless tag_ids

      tag_ids.each do |tag_id|
        AddTagToItem.call(
          auth: auth,
          item_id: item.id,
          tag_id: tag_id
        )
      end
    end

    def self.handle_contacts(auth:, item:, contacts:)
      return unless contacts

      contacts.each do |contact_data|
        CreateContactToItem.add_item_contact(
          item: item,
          contact_data: contact_data
        )
      end
    end

    def self.add_item_for_owner(owner:, item_data:)
      new_item = item_data.clone
      new_item['type'] = new_item['type'].to_sym # Convert string to enum
      owner.add_item(new_item)
    end
  end
end
