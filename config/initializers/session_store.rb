require "redis"


rails_max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
pool_size = Integer(ENV.fetch("REDIS_POOL_SIZE", rails_max_threads))

redis_url = if ENV["REDIS_URL"].present?
  ENV["REDIS_URL"]
else
  host = ENV.fetch("REDIS_HOST", "localhost")
  port = ENV.fetch("REDIS_PORT", "6379")
  db   = ENV.fetch("REDIS_DB", "0")
  password = ENV["REDIS_PASSWORD"]
  url = "redis://#{host}:#{port}/#{db}"
  url = url.sub("redis://", "redis://:#{CGI.escape(password)}@") if password.present?
  url
end

Rails.application.config.session_store :redis_session_store,
  key: "_nezhdanchik_session",
  redis: {
    expire_after: 30.days,
    url: redis_url,
    key_prefix: "nezhdanchik:session:"
  }
