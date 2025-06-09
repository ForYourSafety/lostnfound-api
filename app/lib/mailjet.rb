# frozen_string_literal: true

require 'http'

# Send emails using Mailjet
class Mailjet
  class EmailProviderError < StandardError; end

  class MailContact
    attr_accessor :email, :name

    def initialize(email:, name: nil)
      @email = email
      @name = name
    end

    def to_h
      if @name
        { Email: @email, Name: @name }
      else
        { Email: @email }
      end
    end
  end

  def self.setup(from:, api_key:, api_secret:, api_url: 'https://api.mailjet.com/v3.1/send')
    @from = from
    @api_key = api_key
    @api_secret = api_secret
    @api_url = api_url
  end

  def self.send_email(to:, subject:, body:)
    raise EmailProviderError, 'Mailjet not configured' unless @from && @api_key && @api_secret

    to = [to] if to.is_a?(MailContact)

    request =
      {
        Messages: [
          {
            From: @from.to_h,
            To: to.map(&:to_h),
            Subject: subject,
            HTMLPart: body
          }
        ]
      }

    res = HTTP.basic_auth(user: @api_key, pass: @api_secret)
              .post(@api_url, json: request)

    raise EmailProviderError, "#{res.status} #{res.body}" if res.status >= 300
  end
end
