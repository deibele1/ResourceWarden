lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ResourceWarden/version"

Gem::Specification.new do |spec|
  spec.name          = "resource_warden"
  spec.homepage      = "https://github.com/deibele1/ResourceWarden"
  spec.version       = ResourceWarden::VERSION
  spec.authors       = ["Aaron Deibele"]
  spec.email         = ["deibele1@gmail.com"]

  spec.summary       = %q{Ensures exclusive access to multiple resource across many threads.}
  spec.description   = %q{Allows exclusive resources to be created which can be requested in lists. Requests for the resources guarantee a resource will be granted provided the jobs sent to the warden all finish at some point}
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
