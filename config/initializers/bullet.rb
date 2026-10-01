if Rails.env.development? || Rails.env.test?
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.raise = Rails.env.test?
    Bullet.add_footer = Rails.env.development?
  end
end
