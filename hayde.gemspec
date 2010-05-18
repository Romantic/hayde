# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hayde}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Roman Zaharenkov"]
  s.date = %q{2010-05-18}
  s.description = %q{Helper for generating guides articles from textile source. Extracted from railties-3.0.0.beta3 project. }
  s.email = %q{ZaharenkovRoman@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "Gemfile",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "hayde.gemspec",
     "lib/hayde.rb",
     "lib/hayde/file_utils.rb",
     "lib/hayde/generator.rb",
     "lib/hayde/helpers.rb",
     "lib/hayde/indexer.rb",
     "lib/hayde/levenshtein.rb",
     "lib/hayde/textile_extensions.rb",
     "lib/tasks/haydetasks.rb",
     "test/helper.rb",
     "test/test_hayde.rb"
  ]
  s.homepage = %q{http://github.com/Romantic/hayde}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Textile guides generator like rails-guides.}
  s.test_files = [
    "test/helper.rb",
     "test/test_hayde.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<RedCloth>, [">= 4.1.1"])
      s.add_runtime_dependency(%q<actionpack>, ["= 3.0.0.beta3"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<RedCloth>, [">= 4.1.1"])
      s.add_dependency(%q<actionpack>, ["= 3.0.0.beta3"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<RedCloth>, [">= 4.1.1"])
    s.add_dependency(%q<actionpack>, ["= 3.0.0.beta3"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end

