# frozen_string_literal: true

module LostNFound
  class ContactPolicy # rubocop:disable Style/Documentation
    def initialize(account, contact)
      @account = account
      @contact = contact
    end

    def can_create?
      owns_item?
    end

    def can_view?
      owns_item?
    end

    def can_edit?
      owns_item?
    end

    def can_delete?
      owns_item?
    end

    def summary
      {
        can_create: can_create?,
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def owns_item?
      @contact.item.created_by == @account.id
    end
  end
end
