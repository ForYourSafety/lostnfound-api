# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      uuid :id, primary_key: true

      String :username, null: false, unique: true
      String :email, null: false
      String :password_digest

      String :student_id
      String :name_on_id

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
