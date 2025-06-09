# frozen_string_literal: true

require 'rack/utils'

module LostNFound
  # Notify the item poster when a request is made for their item
  class SendItemRequestNotification
    def initialize(item:, request:)
      @item = item
      @request = request
    end

    def subject = "[LostNFound] Someone is requesting your contacts about the item: #{@item.name}"

    def html_mail
      item_name = Rack::Utils.escape_html(@item.name)
      item_description = if @item.description
                           Rack::Utils.escape_html(@item.description)
                         else
                           'No description provided.'
                         end

      challenge_question = @item.challenge_question ? Rack::Utils.escape_html(@item.challenge_question) : nil
      request_message = Rack::Utils.escape_html(@request.message)

      <<~HTML
        <h1>Contact Request Received</h1>
        <p>
        Dear user, <br><br>
        Someone is requesting your contact information regarding the item you posted on LostNFound:
        </p>
        <p>
        <strong>Item Name:</strong> #{item_name}<br>
        <strong>Description:</strong> #{item_description}<br>
        </p>
        #{ challenge_question && <<~HTML
          <p>
          <strong>Challenge Question:</strong> #{challenge_question}<br>
          </p>
        HTML
        }
        <p>
        <strong>Their message:</strong><br> #{request_message}<br>
        </p>
        <p>Click <a href="#{Api.config.APP_URL}/items/#{@item.id}/requests#request-#{@request.id}">here</a> to view and approve or decline the request.</p>
        <p>
        If you approve the request, the requester will be able to view the contact information you specified on the item, and they will be able to contact you directly.<br>
        If you choose to decline the request, the requester will not receive your contact details.
        </p>
        <p>Best regards,<br>LostNFound Team</p>
      HTML
    end

    def call
      to = Mailjet::MailContact.new(
        email: @item.creator.email,
        name: @item.creator.username
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
