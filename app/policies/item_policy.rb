# frozen_string_literal: true

module LostNFound
  # Item policy for accounts

  class ItemPolicy # rubocop:disable Style/Documentation
    def initialize(auth, item, auth_scope = nil)
      @account = auth.account if auth
      @item = item
      @auth_scope = auth_scope.nil? ? auth.scope : auth_scope
    end

    def can_view?
      true
    end

    def can_edit?
      can_write? && item_poster? && !item_resolved?
    end

    def can_delete?
      can_write? && item_poster?
    end

    def can_resolve?
      item_poster? && !item_resolved?
    end

    def can_add_contact?
      can_write? && item_poster?
    end

    def can_remove_contact?
      can_write? && item_poster?
    end

    def can_view_contacts?
      item_poster? || (request_approved? && !item_resolved?)
    end

    def can_add_tag?
      can_write? && item_poster?
    end

    def can_remove_tag?
      can_write? && item_poster?
    end

    def can_request?
      logged_in? && !can_view_contacts? && !item_resolved?
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_resolve: can_resolve?,
        can_request: can_request?,
        can_add_contact: can_add_contact?,
        can_remove_contact: can_remove_contact?,
        can_view_contacts: can_view_contacts?,
        can_add_tag: can_add_tag?,
        can_remove_tag: can_remove_tag?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('items') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('items') : false
    end

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
