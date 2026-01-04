
require 'spec_helper'


ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Критическая проверка: предотвращает запуск тестов в production, чтобы не повредить реальные данные
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

begin
  # Синхронизирует структуру тестовой БД со схемой db/schema.rb перед запуском тестов
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

require 'shoulda/matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # Путь к фикстурам (YAML). Актуально, если не используется исключительно FactoryBot.

  # Оборачивает каждый тест в транзакцию и откатывает её в конце.
  # Это обеспечивает скорость и изоляцию тестов (чистая БД на каждом примере).
  config.use_transactional_fixtures = true

  # Автоматически определяет тип теста (controller, model, request) по расположению файла
  config.infer_spec_type_from_file_location!

  # Скрывает внутренние вызовы Rails в backtrace, оставляя только стек приложения (удобно для отладки)
  config.filter_rails_from_backtrace!

  # Добавляет хелперы маршрутов (root_path, user_path и т.д.) во все типы тестов
  config.include Rails.application.routes.url_helpers

  # Добавляет методы travel_to для манипуляции временем внутри тестов
  config.include ActiveSupport::Testing::TimeHelpers

  # Добавляет методы Devise (sign_in, sign_out) для тестов контроллеров
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Позволяет вызывать методы FactoryBot коротко: create(:user) вместо FactoryBot.create(:user)
  config.include FactoryBot::Syntax::Methods
end
