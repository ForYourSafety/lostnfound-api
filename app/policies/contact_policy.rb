# frozen_string_literal: true

module LostNFound
  class ContactPolicy # rubocop:disable Style/Documentation
    def initialize(requestor, item)
      @requestor = requestor
      @item = item
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
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?
      }
    end

    private

    def owns_item?
      @item.creator == @requestor
    end
  end
end
