require 'rubygems'
require 'rake'
require "bundler"
Bundler.setup

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hayde"
    gem.summary = %Q{Textile guides generator like rails-guides.}
    gem.description = %Q{Helper for generating guides articles from textile source. Extracted from railties-3.0.0.beta3 project. }
    gem.email = "ZaharenkovRoman@gmail.com"
    gem.homepage = "http://github.com/Romantic/hayde"
    gem.authors = ["Roman Zaharenkov"]
    gem.add_dependency('RedCloth', '>= 4.1.1')
    gem.add_dependency('actionpack', '= 3.0.0.beta3')
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    
    gem.files.include %w(lib/hayde/**/*)

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new(:yardoc) do |t|
  t.files = FileList['lib/**/*.rb'].exclude('lib/hayde/templates/**/*.rb')
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hayde #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
