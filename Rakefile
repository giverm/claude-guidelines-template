require 'rake/testtask'

# Default task
task default: :test

# Test task
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

# Build task (runs build script)
desc 'Build all CLAUDE.local.md files'
task :build do
  ruby 'build.rb'
end

# Watch task (runs build in watch mode)
desc 'Watch for changes and rebuild automatically'
task :watch do
  ruby 'build.rb', '--watch'
end

# Verify task (run tests + build)
desc 'Run tests and build all files'
task verify: [:test, :build] do
  puts "\n✅ All tests passed and files built successfully!"
end
