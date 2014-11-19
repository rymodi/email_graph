# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email_graph/version'

Gem::Specification.new do |spec|
  spec.name          = "email_graph"
  spec.version       = EmailGraph::VERSION
  spec.authors       = ["Ryan Dick"]
  spec.email         = ["rmdick@gmail.com"]
  spec.summary       = %q{Graph data from emails.}
  spec.homepage      = "https://github.com/rymodi/email_graph"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "normailize", '~> 0.0.1'

  # For the GmailFetcher
  spec.add_runtime_dependency "gmail_xoauth", '~> 0.4.1'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", '~> 3.1.0'
end
