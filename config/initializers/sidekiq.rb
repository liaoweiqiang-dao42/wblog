Sidekiq.configure_server do |config|
  config.redis = { 
    host: ENV['REDIS_HOST'].presence || '127.0.0.1',
    port: ENV['REDIS_PORT'].presence || '6379',
    password: ENV['REDIS_PASSWORD'].presence || 'FcoCEZmp',
    db: ENV['SIDEKIQ_DB'].presence || '1' 
  }
end

Sidekiq.configure_client do |config|
  config.redis = { 
    host: ENV['REDIS_HOST'].presence || '127.0.0.1',
    port: ENV['REDIS_PORT'].presence || '6379',
    password: ENV['REDIS_PASSWORD'].presence || 'FcoCEZmp',
    db: ENV['SIDEKIQ_DB'].presence || '1' 
  }
end
