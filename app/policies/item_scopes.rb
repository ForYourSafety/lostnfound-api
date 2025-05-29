# frozen_string_literal: true

module LostNFound
  class ItemPolicy
    # Scope for items viewable by an account
    class AccountScope
      def initialize(current_account, target_account = nil)
        @current_account = current_account
        @target_account = target_account || current_account
      end

      def viewable
        # so far everyone can view items, this is still under construction
        Item.all
      end
    end
  end
end
