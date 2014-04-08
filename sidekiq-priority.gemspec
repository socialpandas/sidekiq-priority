require File.expand_path('../lib/sidekiq/priority/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{Prioritize Sidekiq jobs within queues}
  s.homepage      = 'https://github.com/socialpandas/sidekiq-priority'

  s.files         = Dir['{lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.md']
  s.name          = 'sidekiq-priority'
  s.require_paths = ['lib']
  s.version       = Sidekiq::Priority::VERSION
  s.license       = 'MIT'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-rcov'

  s.add_dependency 'sidekiq', '~> 2.17.0'
end
