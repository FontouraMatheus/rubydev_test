# spec/support/sidekiq.rb
require 'sidekiq/testing'
Sidekiq::Testing.fake! # Usaremos o modo fake, que não executa os jobs, apenas simula a execução.
