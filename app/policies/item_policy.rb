# frozen_string_literal: true

module LostNFound
  # Item policy for accounts

  class ItemPolicy # rubocop:disable Style/Documentation
    def initialize(auth, item)
      @account = auth.account if auth
      @item = item
    end

    def can_view?
      true
    end

    def can_edit?
      item_poster?
    end

    def can_delete?
      item_poster?
    end

    def can_add_contact?
      item_poster?
    end

    def can_remove_contact?
      item_poster?
    end

    def can_view_contacts?
      item_poster? || request_approved?
    end

    def can_add_tag?
      item_poster?
    end

    def can_remove_tag?
      item_poster?
    end

    def can_request?
      logged_in? && !item_poster? && !item_resolved?
    end

    def summary
      {
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_request: can_request?,
        can_add_contact: can_add_contact?,
        can_remove_contact: can_remove_contact?,
        can_view_contacts: can_view_contacts?,
        can_add_tag: can_add_tag?,
        can_remove_tag: can_remove_tag?
      }
    end

    private

    def logged_in?
      !@account.nil?
    end

    def item_poster?
      logged_in? && @item.created_by == @account.id
    end

    def item_resolved?
      @item.resolved == 1
    end

    def request_approved?
      logged_in? && @item.requests.any? do |request|
        request.status == :approved && request.requester_id == @account.id
      end
    end
  end
end
