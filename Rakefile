# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/rdoctask'

NAME = "devise_facebook_connectable"
SUMMARY = %{Devise << Facebook Connect.}
HOMEPAGE = "http://github.com/grimen/#{NAME}"
AUTHORS = ["Jonas Grimfelt"]
EMAIL = "grimen@gmail.com"
SUPPORT_FILES = %w(README)

begin
  gem 'jeweler'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = NAME
    gemspec.summary     = SUMMARY
    gemspec.description = SUMMARY
    gemspec.homepage    = HOMEPAGE
    gemspec.authors     = AUTHORS
    gemspec.email       = EMAIL
    
    gemspec.require_paths = %w{lib}
    gemspec.files = SUPPORT_FILES << %w(Rakefile) <<
      Dir.glob(File.join(*%w[{generators,lib} ** *]).to_s)
    gemspec.extra_rdoc_files = SUPPORT_FILES
    
    gemspec.add_dependency 'activesupport',   '>= 2.3.0'
    gemspec.add_dependency 'devise',          '>= 0.7.3'
    gemspec.add_dependency 'facebooker',      '>= 1.0.55'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler - or one of its dependencies - is not available. " <<
        "Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

desc %Q{Generate documentation for "#{NAME}".}
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = NAME
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include(SUPPORT_FILES)
  rdoc.rdoc_files.include(File.join(*%w[lib ** *.rb]))
end