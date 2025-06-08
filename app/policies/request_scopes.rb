# frozen_string_literal: true

module LostNFound
  # Request policy for accounts
  class RequestPolicy
    # Scope of requests of an account
    class AccountScope
      def initialize(current_account)
        @current_account = current_account
        @full_scope = all_requests
      end

      def mine
        @full_scope.where(requested_by: @current_account.id).all
      end

      def to_me
        return [] if @current_account.nil?

        @full_scope.join(:items, id: :item_id).where(Sequel[:items][:created_by] => @current_account.id).all
      end

      private

      def all_requests
        Request.order(:created_at).reverse
      end
    end

    # Scope of request policies of an item
    class AccountItemScope
      def initialize(current_account, item)
        @current_account = current_account
        @item = item
        @full_scope = all_requests_to_item
      end

      def viewable
        return [] if @current_account.nil?

        if @item.created_by == @current_account.id
          @full_scope.all # Item owner sees all requests
        else
          @full_scope.where(requested_by: @current_account.id).all # Non-owners see only their own requests
        end
      end

      private

      def all_requests_to_item
        Request.where(item_id: @item.id).order(:created_at).reverse
      end
    end
  end
end
