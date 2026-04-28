# frozen_string_literal: true

require_relative "lib/ground_control/api/version"

Gem::Specification.new do |spec|
  spec.name = "ground_control-api"
  spec.version = GroundControl::Api::VERSION
  spec.authors = ["Jaryl Sim"]
  spec.email = ["code@jaryl.dev"]

  spec.summary = "Headless JSON API for managing Active Job queues, jobs, workers, and recurring tasks"
  spec.description = "A Rails engine providing a JSON API layer on top of mission_control-jobs. " \
                     "Use standalone or as the foundation for ground_control-inertia."
  spec.homepage = "https://github.com/rarebit-one/ground_control-api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rarebit-one/ground_control-api"
  spec.metadata["changelog_uri"] = "https://github.com/rarebit-one/ground_control-api/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/rarebit-one/ground_control-api/issues"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ .claude/ Gemfile .gitignore .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "alba", ">= 3.0"
  spec.add_dependency "mission_control-jobs", ">= 0.6"
  spec.add_dependency "rails", ">= 8.0"

  spec.add_development_dependency "simplecov", "~> 0.22"
end
