# frozen_string_literal: true

# If an account can view, edit, or delete this account
class AccountPolicy
  def initialize(auth, account)
    @account = auth.account if auth
    @this_account = account
  end

  def can_view?
    self_request?
  end

  def can_edit?
    self_request?
  end

  def can_delete?
    self_request?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def logged_in?
    !@account.nil?
  end

  def self_request?
    logged_in? && @account == @this_account
  end
end
