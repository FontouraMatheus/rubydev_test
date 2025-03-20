# spec/support/sidekiq.rb
require 'sidekiq/testing'
Sidekiq::Testing.fake!
