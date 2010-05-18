require 'rake'
require 'rake/clean'

CLOBBER.include('docs/guides')

namespace :hayde do
  desc "Generates guides documentation."
  task :build do
	guides_generator = Hayde::Generator.new do |g|
	  g.sources.include 'guides/source/**/*'
	  g.sources.exclude 'guides/source/layout.*'
	end
	guides_generator.generate
  end

  desc "Generates guides documentation."
  task :rebuild do
	guides_generator = Hayde::Generator.new do |g|
	  g.sources.include 'guides/source/**/*'
	  g.sources.exclude 'guides/source/layout.*'
	  g.force = true
	end
	guides_generator.generate
  end

  desc "Removes generated guides."
  task :clean do
	guides_generator = Hayde::Generator.new
	guides_generator.clean
  end
end