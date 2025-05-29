# frozen_string_literal: true

# Policy to determine if account can view a project
class AccountPolicy
  def initialize(requestor, account)
    @requestor = requestor
    @account = account
  end

  def can_view?
    self_request?
  end

  def can_update?
    self_request?
  end

  def can_delete?
    self_request?
  end

  def summary
    {
      can_view: can_view?,
      can_update: can_update?,
      can_delete: can_delete?
    }
  end

  private

  def self_request?
    @requestor == @account
  end
end
