# frozen_string_literal: true

module LostNFound
  ## Send email verification email
  # params:
  #   - registration: hash with keys :username :email :verification_url :exp
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end

    def initialize(registration)
      @registration = registration
    end

    def call
      raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidRegistration, 'Email already used') unless email_available?

      send_email_verification
    end

    def username_available?
      Account.first(username: @registration[:username]).nil?
    end

    def email_available?
      Account.first(email: @registration[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <H1>LostNFound Platform Registration</H1>
        <p>Please <a href="#{@registration[:verification_url]}">click here</a>
        to validate your email.
        You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end

    def send_email_verification # rubocop:disable Metrics/MethodLength
      to = Mailjet::MailContact.new(
        email: @registration[:email],
        name: @registration[:username]
      )

      Mailjet.send_email(
        to: to,
        subject: '[LostNFound] Registration Verification',
        body: html_email
      )
    rescue Mailjet::EmailProviderError => e
      Api.logger.error "Email provider error: #{e.inspect}"
      raise Mailjet::EmailProviderError
    rescue StandardError => e
      Api.logger.error "Verify registration error: #{e.inspect}, trace: #{e.backtrace}"
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end
