# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Secret credentials not exposed' do
  it 'should not find database url' do
    _(LostNFound::Api.config.DATABASE_URL).must_be_nil
  end
end
