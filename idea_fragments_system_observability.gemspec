# frozen_string_literal: true

require_relative "lib/system_observability/version"

Gem::Specification.new do |spec|
  spec.name = "idea_fragments_system_observability"
  spec.version = SystemObservability::VERSION
  spec.authors = ["Sam"]
  spec.email = ["sam@ideafragments.com"]

  spec.summary = "System Observability for Ruby"
  spec.description = ""
  spec.homepage = "https://github.com/idea-fragments/system_observability_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.2"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/idea-fragments/system_observability_ruby"
  spec.metadata["changelog_uri"] = "https://github.com/idea-fragments/system_observability_ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "bugsnag", "~> 6.24"
  spec.add_dependency "dogstatsd-ruby", "~> 5.5"
  spec.add_dependency "newrelic_rpm", "~> 8.9"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "sidekiq", "~> 6.5"

  spec.add_development_dependency "faker"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rspec", "~> 2.10"
  spec.add_development_dependency "timecop", "~> 0.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
