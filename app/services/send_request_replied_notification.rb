# frozen_string_literal: true

require 'rack/utils'

module LostNFound
  # Notify the requester that their request has been replied
  class SendRequestRepliedNotification
    def initialize(request:)
      @request = request
    end

    def subject
      if @request.approved?
        "[LostNFound] Your contact request for #{@request.item.name} has been approved"
      else
        "[LostNFound] Your contact request for #{@request.item.name} has been declined"
      end
    end

    def html_mail # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      item_name = Rack::Utils.escape_html(@request.item.name)
      item_description = if @request.item.description
                           Rack::Utils.escape_html(@request.item.description)
                         else
                           'No description provided.'
                         end

      if @request.approved?
        <<~HTML
          <h1>Contact Request Approved</h1>
          <p>
          Dear user, <br><br>
          Your contact request to the item has been approved:
          </p>
          <p>
          <strong>Item Name:</strong> #{item_name}<br>
          <strong>Description:</strong> #{item_description}<br>
          </p>
          <p>
          You can now view the contact information of the item poster on the item page and contact them directly.
          </p>
          <p>Click <a href="#{Api.config.APP_URL}/items/#{@request.item.id}">here</a> to view their contact information.</p>
          <p>Best regards,<br>LostNFound Team</p>
        HTML
      else
        <<~HTML
          <h1>Contact Request Declined</h1>
          <p>
          Dear user, <br><br>
          We are sorry to inform you that your contact request to the item has been declined by the item poster:
          </p>
          <p>
          <strong>Item Name:</strong> #{item_name}<br>
          <strong>Description:</strong> #{item_description}<br>
          </p>
          <p>
          The item poster has chosen not to share their contact information with you at this time.<br>
          But you can still send another request <a href="#{Api.config.APP_URL}/items/#{@request.item.id}">here</a> if you believe you have a valid reason to contact them.
          </p>
          <p>Best regards,<br>LostNFound Team</p>
        HTML
      end
    end

    def call # rubocop:disable Metrics/MethodLength
      to = Mailjet::MailContact.new(
        email: @request.requester.email,
        name: @request.requester.username
      )

      Mailjet.send_email(
        to: to,
        subject: subject,
        body: html_mail
      )
    rescue Mailjet::EmailProviderError => e
      Api.logger.error "Email provider error: #{e.inspect}"
    end
  end
end
