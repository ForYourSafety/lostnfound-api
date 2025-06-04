# frozen_string_literal: true

module LostNFound
  # Item policy for accounts

  class ItemPolicy # rubocop:disable Style/Documentation
    def initialize(account, item)
      @account = account
      @item = item
    end

    def can_view?
      owns_item?
    end

    # def can_create? 這個要嗎 待討論
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
      @item.created_by == @account.id
    end
  end
end
