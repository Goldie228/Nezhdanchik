
require "redis"

# Вычисление оптимального размера пула соединений на основе настроек веб-сервера (Puma)
rails_max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
pool_size = Integer(ENV.fetch("REDIS_POOL_SIZE", rails_max_threads))

redis_url = if ENV["REDIS_URL"].present?
  # Используем готовый URL, если он задан в переменных окружения (стандарт для контейнеров/хостинга)
  ENV["REDIS_URL"]
else
  # Формируем URL вручную из переменных для гибкости локальной настройки
  host = ENV.fetch("REDIS_HOST", "localhost")
  port = ENV.fetch("REDIS_PORT", "6379")
  db   = ENV.fetch("REDIS_DB", "0")
  password = ENV["REDIS_PASSWORD"]

  url = "redis://#{host}:#{port}/#{db}"
  # Безопасное экранирование пароля для подстановки в URL
  url = url.sub("redis://", "redis://:#{CGI.escape(password)}@") if password.present?
  url
end

# Настройка хранилища сессий в Redis вместо cookie_store.
# Это безопаснее (данные не покидают сервер) и позволяет реализовать "выйти на всех устройствах".
Rails.application.config.session_store :redis_session_store,
  key: "_nezhdanchik_session",             # Имя cookie в браузере
  redis: {
    expire_after: 30.days,                  # Время жизни сессии в Redis (авто-удаление по TTL)
    url: redis_url,                        # Строка подключения
    key_prefix: "nezhdanchik:session:"      # Префикс ключей для удобства мониторинга и разделения данных
  }
