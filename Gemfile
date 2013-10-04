source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '4.0.0'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'

gem 'openid_connect'
gem 'quiet_assets'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'sqlite3'
end

group :test do
  gem 'turn', :require => false
end

group :production do
  gem 'pg'
  gem 'rack-ssl', :require => 'rack/ssl'
end
