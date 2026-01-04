
require "redis"
require "connection_pool"

# Количество потоков в Rails (берется из конфигурации или по умолчанию 5)
rails_max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
# Размер пула соединений к Redis. Обычно равен количеству потоков для максимальной производительности.
pool_size = Integer(ENV.fetch("REDIS_POOL_SIZE", rails_max_threads))

redis_url = if ENV["REDIS_URL"].present?
  # Приоритет полной строке подключения из переменных окружения (стандарт для продакшена)
  ENV["REDIS_URL"]
else
  # Сборка URL подключения из отдельных переменных для гибкости конфигурации
  host = ENV.fetch("REDIS_HOST", "localhost")
  port = ENV.fetch("REDIS_PORT", "6379")
  db   = ENV.fetch("REDIS_DB", "0")
  password = ENV["REDIS_PASSWORD"]

  url = "redis://#{host}:#{port}/#{db}"
  # Экранирование пароля для корректного формирования URL (если содержит спецсимволы)
  url = url.sub("redis://", "redis://:#{CGI.escape(password)}@") if password.present?
  url
end

# Одиночный клиент для фоновых задач (Sidekiq) или скриптов, где не нужна многопоточность
REDIS_CLIENT = Redis.new(url: redis_url)

# Пул соединений для веб-приложения.
# ConnectionPool переиспользует соединения, что снижает нагрузку на handshake (рукопожатие) с Redis.
# Критично для веб-серверов (Puma), где множество запросов идут одновременно.
REDIS_POOL = ConnectionPool.new(size: pool_size, timeout: 5) do
  Redis.new(url: redis_url)
end
