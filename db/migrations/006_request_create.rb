# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:requests) do
      uuid :id, primary_key: true

      foreign_key :item_id, :items, type: :uuid, null: false
      foreign_key :requester_id, :accounts, type: :uuid, null: false

      String :message, null: false
      Integer :status, null: false, default: 0 # 0 = UNANSWERED, 1 = APPROVED, 2 = DECLINED

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
