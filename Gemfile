# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.3.0'

gem 'rake', '>= 13.0'
gem 'pkg-config', '>= 1.5.0'              # Required by mkmf-gnome.rb during native extension compilation
gem 'native-package-installer', '>= 1.1' # Required by mkmf-gnome.rb for system package detection

group :development do
  gem 'rubocop', require: false
end

group :test do
  gem 'minitest', '>= 5.0'
end
