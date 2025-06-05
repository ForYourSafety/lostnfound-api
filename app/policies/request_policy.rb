# frozen_string_literal: true

module LostNFound
  # Item policy for accounts

  class RequestPolicy # rubocop:disable Style/Documentation
    def initialize(auth, request)
      @account = auth.account if auth
      @request = request
    end

    def can_view?
      item_poster? || requester?
    end

    def can_delete?
      requester?
    end

    def can_reply?
      !answered? && item_poster?
    end

    def summary
      {
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_reply: can_reply?
      }
    end

    private

    def logged_in?
      !@account.nil?
    end

    def item_poster?
      logged_in? && @request.item.created_by == @account.id
    end

    def requester?
      logged_in? && @request.requester_id == @account.id
    end

    def answered?
      @request.status != :unanswered
    end
  end
end
