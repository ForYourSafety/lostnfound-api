# frozen_string_literal: true

require 'aws-sdk-s3'

# Storage with S3
class S3Storage
  def self.setup(bucket:, endpoint:, region:, access_key_id:, secret_access_key:)
    @client = Aws::S3::Client.new(
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      endpoint: endpoint,
      region: region,
      force_path_style: true,
      request_checksum_calculation: 'when_required',
      response_checksum_validation: 'when_required'
    )
    @bucket = bucket
  end

  def self.upload(object_key:, contents:, content_type:, acl: 'public-read')
    @client.put_object(
      bucket: @bucket,
      key: object_key,
      body: contents,
      content_type: content_type,
      acl: acl
    )
  end

  def self.delete(object_key:)
    @client.delete_object(
      bucket: @bucket,
      key: object_key
    )
  end
end
