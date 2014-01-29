# Encoding: UTF-8

Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'refinerycms-blog2'
  s.version           = '1.0.0'
  s.description       = 'Ruby on Rails Blog extension for Refinery CMS'
  s.date              = '2013-09-01'
  s.summary           = 'Blog extension for Refinery CMS - compatible with refinerycms version 2.718.0.dev'
  s.email             = %q{nospam.keram@gmail.com}
  s.homepage          = %q{http://refinery.sk}
  s.authors           = ['Marek Labos']
  s.license           = 'MIT'
  s.require_paths     = %w(lib)
  s.files             = Dir["{app,config,db,lib}/**/*"] + ["readme.md"]

  # Runtime dependencies
  s.add_dependency             'refinerycms-core',    '~> 2.718.0.dev'
  s.add_dependency             'refinerycms-imageable', '~> 0.0.1'
  s.add_dependency             'acts-as-taggable-on', '~> 3.0.1'

  # Development dependencies (usually used for testing)
  s.add_development_dependency 'refinerycms-testing', '~> 2.718.0.dev'
end
