# frozen_string_literal: true

module LostNFound
  # Item policy for accounts
  class ItemPolicy
    # Scope of item policies
    class AccountScope
      def initialize(current_account)
        @current_account = current_account
        @full_scope = all_items
      end

      def public_view
        @full_scope.where(resolved: false).all
      end

      def mine
        return nil if @current_account.nil?

        @full_scope.where(created_by: @current_account.account.id).all
      end

      private

      def all_items
        Item.order(:created_at).reverse
      end
    end
  end
end
