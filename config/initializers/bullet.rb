# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  Rails.application.config.after_initialize do
    Bullet.enable = true
    Bullet.raise = Rails.env.test?
    Bullet.rails_logger = true
    Bullet.console = Rails.env.development?
    Bullet.add_footer = Rails.env.development?
  end
end
