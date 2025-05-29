# frozen_string_literal: true

class ItemPolicy # rubocop:disable Style/Documentation
  def initialize(account, item)
    @account = account
    @item = item
  end

  def can_create?
    @account.present?
  end

  def can_view?
    true
  end

  def can_update?
    owns_item?
  end

  def can_delete?
    owns_item?
  end

  def summary
    {
      can_create: can_create?,
      can_view: can_view?,
      can_update: can_update?,
      can_delete: can_delete?
    }
  end

  private

  def owns_item?
    @item.creator == @account
  end
end
