pwd = File.dirname(__FILE__)
$:.unshift pwd

# Loading Action Pack requires rack and erubis.
require 'rubygems'

begin
  # Guides generation in the Rails repo.
  as_lib = File.join(pwd, "../../activesupport/lib")
  ap_lib = File.join(pwd, "../../actionpack/lib")

  $:.unshift as_lib if File.directory?(as_lib)
  $:.unshift ap_lib if File.directory?(ap_lib)
rescue LoadError
  # Guides generation from gems.
  gem "actionpack", '>= 3.0'
end

begin
  gem 'RedCloth', '>= 4.1.1'
  require 'redcloth'
rescue Gem::LoadError
  $stderr.puts %(Generating Guides requires RedCloth 4.1.1+)
  exit 1
end

require 'hayde/generator'
require 'hayde/textile_extensions'

RedCloth.send(:include, Hayde::TextileExtensions)

Dir.glob(File.join(pwd, 'tasks', '*.rb')).each { |task| require task }