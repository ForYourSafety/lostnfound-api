# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'logger', '~> 1.0'
gem 'mimemagic'
gem 'puma', '~>6.0'
gem 'rack', '~>3.1.16'
gem 'roda', '~>3.0'

# Configuration
gem 'figaro', '~>1.2'
gem 'rake'

# Security
gem 'rbnacl', '~>7.1'

# Database
gem 'hirb', '~>0.7'
gem 'sequel', '~>5.67'
gem 'sequel_enum', '~> 0.2.0'
group :production do
  gem 'pg'
end

# Data Encoding and Formatting
gem 'base64'
gem 'json'

# External Services
gem 'aws-sdk-s3'
gem 'http'

# Debugging
gem 'pry'
gem 'rack-test'

# Development
group :development do
  # Debugging
  gem 'rerun'

  # Quality
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-sequel'

  # Audit
  gem 'bundler-audit'
end

# Dev/test Database
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'webmock'
end

# Code Quality
gem 'sorbet', group: :development
gem 'sorbet-runtime'
gem 'tapioca', require: false, group: %i[development test]
