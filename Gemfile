source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 8.1.3'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 2.1'
# Postgres (quitar sqlite3)
# gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 7.2'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/shakacode/shakapacker
gem 'shakapacker', '~> 10.3'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.13'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.12'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.18', require: false

# Autenticación
gem 'devise', '~> 5.0', '>= 5.0.4'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Reporta dependencias con vulnerabilidades conocidas
  gem 'bundler-audit', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.2.1'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.3'
  gem 'listen', '~> 3.9'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.40'
  # selenium-webdriver >= 4.11 resuelve los drivers por sí solo (Selenium Manager),
  # por eso ya no se usa la gema `webdrivers`.
  gem 'selenium-webdriver', '>= 4.27'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# PDF
gem 'wicked_pdf', '~> 2.8'
# no sirve para win
gem 'wkhtmltopdf-binary'
