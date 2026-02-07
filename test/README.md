# Build Script Tests

Comprehensive test suite for `build.rb` to ensure reliability and prevent regressions.

## Running Tests

### Run all tests:
```bash
ruby test/build_test.rb
```

### Run tests with rake:
```bash
rake test
```

### Run tests + build (verify everything):
```bash
rake verify
```

## Test Coverage

### Core Functionality
- ✅ Basic build (combining project + common files)
- ✅ Multiple builds in one run
- ✅ Line count reporting

### File Override Resolution
- ✅ Project-specific overrides replace common files
- ✅ Hierarchical overrides (child → parent → common)
- ✅ Override resolution walks up directory tree

### Skill System
- ✅ Skills copied to output `.claude/skills/` directory
- ✅ Skill directory structure preserved (subdirectories)
- ✅ Hierarchical skill overrides (project → common)

### Error Handling
- ✅ Missing project file (warns, continues)
- ✅ Missing common file (warns, skips)
- ✅ Missing skill (warns, skips)

### Configuration
- ✅ YAML config loading
- ✅ Symbol key conversion
- ✅ Multiple builds configuration

### Skipped Tests
- ⏭️ Symlink creation (requires real target directories)

## Test Isolation

Tests run in temporary directories (`Dir.mktmpdir`) to avoid affecting actual project files:
- Each test gets a clean temporary directory
- No changes to real project files or configs
- Fast teardown after each test

## Adding New Tests

When adding new build features, add corresponding tests:

1. Create test fixtures (minimal test files)
2. Run build with test config
3. Assert expected behavior
4. Clean up in teardown (automatic with tmpdir)

**Example:**
```ruby
def test_new_feature
  # Setup
  create_file('projects/test/main.project.md', "content")
  create_builds_config([{ ... }])

  # Execute
  build_all

  # Assert
  assert File.exist?('output/CLAUDE.local.md')
end
```

## Performance

Test suite runs in ~0.02 seconds:
- 13 tests
- 38 assertions
- No external dependencies
- Fast feedback loop

## CI Integration

These tests can be run in CI/CD:
```bash
# In CI pipeline
rake test || exit 1
```
