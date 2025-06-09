# frozen_string_literal: true

require 'rack/utils'

module LostNFound
  # Notify the owner about the possible lost item
  class SendOwnerNotification
    def initialize(item:, owner_name: nil, owner_student_id: nil)
      @item = item
      @owner_name = owner_name
      @owner_student_id = owner_student_id
    end

    def subject = "[LostNFound] Possible lost item of yours: #{@item.name}"

    def html_mail # rubocop:disable Metrics/MethodLength
      item_name = Rack::Utils.escape_html(@item.name)
      item_description = if @item.description
                           Rack::Utils.escape_html(@item.description)
                         else
                           'No description provided.'
                         end

      <<~HTML
        <h1>Possible Lost Item Notification</h1>
        <p>
        Dear user, <br><br>
        Someone has found an item that matches your details:
        </p>
        <p>
        <strong>Item Name:</strong> #{item_name}<br>
        <strong>Description:</strong> #{item_description}<br>
        </p>
        <p>Click <a href="#{Api.config.APP_URL}/items/#{@item.id}">here</a> to view the item.</p>
        <p>
        If this is your item, please request the contact details of the person who posted it using the LostNFound platform.<br>
        If you believe this is not your item, you can ignore this email.
        </p>
        <p>Best regards,<br>LostNFound Team</p>
      HTML
    end

    def call # rubocop:disable Metrics/MethodLength
      return if @owner_name.nil? && @owner_student_id.nil?

      matches = find_possible_owners
      return if matches.empty?

      to = matches.map do |account|
        Mailjet::MailContact.new(
          email: account.email,
          name: account.username
        )
      end

      Mailjet.send_email(
        to: to,
        subject: subject,
        body: html_mail
      )
    rescue Mailjet::EmailProviderError => e
      Api.logger.error "Email provider error: #{e.inspect}"
    end

    def find_possible_owners
      conditions = []
      conditions << Sequel.like(:name_on_id, "%#{@owner_name}%") if @owner_name
      conditions << Sequel.like(:student_id, "%#{@owner_student_id}%") if @owner_student_id

      Account.where(conditions.reduce(:|)).all
    end
  end
end
