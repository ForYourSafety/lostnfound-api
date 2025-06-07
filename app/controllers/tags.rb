# frozen_string_literal: true

require 'roda'
require_relative 'app'

module LostNFound
  # Web controller for LostNFound API
  class Api < Roda
    route('tags') do |routing|
      @item_route = "#{@api_root}/tags"
      routing.is do
        # GET /api/v1/items
        routing.get do
          tags = LostNFound::Tag.all

          JSON.pretty_generate(data: tags)
        end
      end
    end
  end
end
