# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'devise_facebook_connectable', 'version')

NAME = "devise_facebook_connectable"

begin
  gem 'jeweler'
  require 'jeweler'
  Jeweler::Tasks.new do |spec|
    spec.name         = NAME
    spec.version      = ::Devise::FacebookConnectable::VERSION
    spec.summary      = %{Devise << Facebook Connect.}
    spec.description  = spec.summary
    spec.homepage     = "http://github.com/grimen/#{spec.name}"
    spec.authors      = ["Jonas Grimfelt"]
    spec.email        = "grimen@gmail.com"

    spec.files = FileList['[A-Z]*', File.join(*%w[{generators,lib,rails} ** *]).to_s]

    spec.add_dependency 'activesupport',   '>= 2.3.0'
    spec.add_dependency 'devise',          '>= 1.0.0'
    spec.add_dependency 'facebooker',      '>= 1.0.55'
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
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include(File.join(*%w[lib ** *.rb]))
end