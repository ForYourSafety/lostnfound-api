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

      def viewable
        @full_scope
      end

      private

      def all_items
        Item.all
      end
    end
  end
end
