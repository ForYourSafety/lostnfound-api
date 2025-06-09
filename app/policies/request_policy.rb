# frozen_string_literal: true

module LostNFound
  # Item policy for accounts

  class RequestPolicy # rubocop:disable Style/Documentation
    def initialize(auth, request, auth_scope = nil)
      @account = auth.account if auth
      @request = request
      @auth_scope = auth_scope.nil? ? auth.scope : auth_scope
    end

    def can_view?
      can_read? && (item_poster? || requester?)
    end

    def can_delete?
      can_write? && requester? && !answered?
    end

    def can_reply?
      !answered? && item_poster? && !item_resolved?
    end

    def summary
      {
        can_view: can_view?,
        can_delete: can_delete?,
        can_reply: can_reply?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('documents') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('documents') : false
    end

    def logged_in?
      !@account.nil?
    end

    def item_poster?
      logged_in? && @request.item.created_by == @account.id
    end

    def requester?
      logged_in? && @request.requester_id == @account.id
    end

    def item_resolved?
      @request.item.resolved == 1
    end

    def answered?
      @request.status != :unanswered
    end
  end
end
