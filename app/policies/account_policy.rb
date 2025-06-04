# frozen_string_literal: true

# If an account can view, edit, or delete itself
class AccountPolicy
  def initialize(creator, account)
    @creator = creator
    @account = account
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

  def self_request?
    @creator == @account
  end
end
