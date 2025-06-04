# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:items) do
      uuid :id, primary_key: true

      foreign_key :created_by, :accounts, type: :uuid # allow column to be null

      Integer :type, null: false
      String :name, null: false
      String :description
      String :location
      String :challenge_question
      Integer :resolved, default: 0

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
