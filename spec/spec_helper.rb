
RSpec.configure do |config|
  # Настройка механизма ожиданий (expectations)
  config.expect_with :rspec do |expectations|
    # Включает описание цепочек методов (например, .and) в сообщения об ошибках кастомных матчеров
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Настройка механизма заглушек и моков (mocks)
  config.mock_with :rspec do |mocks|
    # Проверяет существование методов при "мокании", чтобы избежать ложноположительных тестов
    mocks.verify_partial_doubles = true
  end

  # Управляет тем, как метаданные из shared контекстов наследуются группами тестов
  config.shared_context_metadata_behavior = :apply_to_host_groups
  # Позволяет запускать только тесты с меткой :focus (fit, fdescribe) для целенаправленной отладки
  config.filter_run_when_matching :focus
  # Сохраняет статусы прохождения тестов в файл, чтобы можно было перезапустить только упавшие
  config.example_status_persistence_file_path = "spec/examples.txt"
  # Отключает "monkey patching" глобальных объектов, рекомендуя использовать современный синтаксис expect
  config.disable_monkey_patching!

  # Если для прогона выбран только один файл, переключаем формат вывода на 'doc' для читаемости
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  # Выводит 10 самых медленных тестов по окончании прогона для поиска узких мест
  config.profile_examples = 10
  # Случайный порядок выполнения тестов помогает выявить скрытые зависимости между ними
  config.order = :random

  # Инициализирует генератор случайных чисел заданным сидом (для воспроизведения порядка тестов)
  Kernel.srand config.seed
end
