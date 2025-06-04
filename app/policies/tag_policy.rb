# frozen_string_literal: true

module LostNFound
  # Item policy for accounts

  class TagPolicy # rubocop:disable Style/Documentation
    def initialize(account, tag)
      @account = account
      @tag = tag
    end

    def can_view?
      owns_item?
    end

    # def can_create?
    #   true
    # end

    def can_edit?
      owns_item?
    end

    def can_delete?
      owns_item?
    end

    def summary
      {
        # can_create: can_create?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def owns_item?
      @tag.item.created_by == @account.id
    end
  end
end
