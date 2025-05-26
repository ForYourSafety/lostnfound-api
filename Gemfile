# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'base64'
gem 'json'
gem 'logger', '~> 1.0'
gem 'puma', '~>6.0'
gem 'roda', '~>3.0'
gem 'rack', '~>3.1.15'

# Configuration
gem 'figaro', '~>1.2'
gem 'rake'

# Security
gem 'rbnacl', '~>7.1'

# Database
gem 'hirb', '~>0.7'
gem 'sequel', '~>5.67'
gem 'sequel_enum', '~> 0.2.0'
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end

# External Services
gem 'http'

# Performance
gem 'rubocop-performance'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'rack-test'
end

# Development
gem 'bundler-audit'
gem 'pry'
gem 'rerun'
gem 'rubocop'
gem 'rubocop-minitest'
gem 'rubocop-rake'
gem 'rubocop-sequel'
gem 'sorbet', group: :development
gem 'sorbet-runtime'
gem 'tapioca', require: false, group: %i[development test]

group :production do
  gem 'pg'
end
