# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "radiant-event_map-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-event_map-extension"
  s.version     = RadiantEventMapExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantEventMapExtension::AUTHORS
  s.email       = RadiantEventMapExtension::EMAIL
  s.homepage    = RadiantEventMapExtension::URL
  s.summary     = RadiantEventMapExtension::SUMMARY
  s.description = RadiantEventMapExtension::DESCRIPTION

  s.add_dependency "geokit", "~> 1.5.0"
  s.add_dependency "radiant-event_calendar-extension", "~> 1.4.4"

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with:

    config.gem 'radiant-event_map-extension', :version => '~> #{RadiantEventMapExtension::VERSION}'

  }
end
