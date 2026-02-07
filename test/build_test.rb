#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'pathname'
require 'tmpdir'
require 'yaml'

# Load the build script
require_relative '../build.rb'

class BuildTest < Minitest::Test
  def setup
    @test_dir = Dir.mktmpdir('build-test')
    @original_dir = Dir.pwd
    Dir.chdir(@test_dir)

    # Create basic directory structure
    FileUtils.mkdir_p('common')
    FileUtils.mkdir_p('projects/test-project')
    FileUtils.mkdir_p('skills/test-skill')

    # Create empty builds.yml to prevent loading real config
    create_builds_config([])
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir)
  end

  # Helper to create a test file
  def create_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  # Helper to create test config
  def create_builds_config(builds)
    File.write('builds.yml', { 'builds' => builds }.to_yaml)
  end

  def test_basic_build
    # Create source files
    create_file('common/_editing-instructions.md', "# Header\n")
    create_file('projects/test-project/main.project.md', "# Test Project\n")
    create_file('common/test-common.md', "# Common Content\n")

    # Create config
    create_builds_config([{
      'name' => 'Test Project',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => ['common/test-common.md']
    }])

    # Run build
    assert build_all, 'Build should succeed'

    # Verify output
    assert File.exist?('output/CLAUDE.local.md'), 'Output file should exist'
    content = File.read('output/CLAUDE.local.md')
    assert_includes content, '# Header', 'Should include header'
    assert_includes content, '# Test Project', 'Should include project content'
    assert_includes content, '# Common Content', 'Should include common content'
  end

  def test_file_override_resolution
    # Create common file
    create_file('common/test.md', "# Common Version\n")

    # Create project override
    create_file('projects/test-project/test.md', "# Project Override\n")
    create_file('projects/test-project/main.project.md', "# Test\n")

    # Create config
    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => ['common/test.md']
    }])

    # Run build
    build_all

    # Verify override was used
    content = File.read('output/CLAUDE.local.md')
    assert_includes content, '# Project Override', 'Should use project override'
    refute_includes content, '# Common Version', 'Should not use common version'
  end

  def test_hierarchical_file_override
    # Create common file
    create_file('common/test.md', "# Common\n")

    # Create parent override
    create_file('projects/parent/test.md', "# Parent Override\n")

    # Create child project (no override)
    create_file('projects/parent/child/main.project.md', "# Child\n")

    # Create config
    create_builds_config([{
      'name' => 'Child',
      'project' => 'projects/parent/child/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => ['common/test.md']
    }])

    # Run build
    build_all

    # Verify parent override was used
    content = File.read('output/CLAUDE.local.md')
    assert_includes content, '# Parent Override', 'Should use parent override'
    refute_includes content, '# Common', 'Should not use common version'
  end

  def test_skill_copying
    # Create skill
    create_file('skills/test-skill/SKILL.md', "# Test Skill\n")
    create_file('projects/test-project/main.project.md', "# Test\n")

    # Create config
    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => [],
      'skills' => ['test-skill']
    }])

    # Run build
    build_all

    # Verify skill was copied
    assert File.exist?('output/.claude/skills/test-skill/SKILL.md'),
           'Skill should be copied to output'
    content = File.read('output/.claude/skills/test-skill/SKILL.md')
    assert_includes content, '# Test Skill', 'Skill content should be correct'
  end

  def test_hierarchical_skill_override
    # Create common skill
    create_file('skills/test-skill/SKILL.md', "# Common Skill\n")

    # Create project override skill
    create_file('projects/test-project/skills/test-skill/SKILL.md', "# Override Skill\n")
    create_file('projects/test-project/main.project.md', "# Test\n")

    # Create config
    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => [],
      'skills' => ['test-skill']
    }])

    # Run build
    build_all

    # Verify override skill was used
    content = File.read('output/.claude/skills/test-skill/SKILL.md')
    assert_includes content, '# Override Skill', 'Should use project override skill'
    refute_includes content, '# Common Skill', 'Should not use common skill'
  end

  def test_symlink_creation
    skip 'Symlink test requires target directory to exist'
    # This test would need a real target directory which we can't create in tmpdir
    # In practice, symlinks are created to actual project directories
  end

  def test_missing_project_file
    # Create config with missing project file
    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/missing/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => []
    }])

    # Capture stderr
    _out, err = capture_io do
      build_all
    end

    # Verify warning was printed
    assert_includes err, 'Project file not found', 'Should warn about missing file'
  end

  def test_missing_common_file
    create_file('projects/test-project/main.project.md', "# Test\n")

    # Create config with missing common file
    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => ['common/missing.md']
    }])

    # Capture stderr
    _out, err = capture_io do
      build_all
    end

    # Verify warning was printed
    assert_includes err, 'not found', 'Should warn about missing common file'
  end

  def test_missing_skill
    create_file('projects/test-project/main.project.md', "# Test\n")

    # Create config with missing skill
    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => [],
      'skills' => ['missing-skill']
    }])

    # Capture stderr
    _out, err = capture_io do
      build_all
    end

    # Verify warning was printed
    assert_includes err, 'Skill not found', 'Should warn about missing skill'
  end

  def test_yaml_config_loading
    # Create valid YAML config
    create_builds_config([
      { 'name' => 'Project 1', 'project' => 'p1.md', 'output' => 'o1.md', 'common' => [] },
      { 'name' => 'Project 2', 'project' => 'p2.md', 'output' => 'o2.md', 'common' => [] }
    ])

    # Load config
    builds = load_builds

    # Verify
    assert_equal 2, builds.length, 'Should load all builds'
    assert_equal 'Project 1', builds[0][:name], 'Should convert keys to symbols'
    assert_equal 'Project 2', builds[1][:name], 'Should load second build'
  end

  def test_line_count_reporting
    create_file('projects/test-project/main.project.md', "Line 1\nLine 2\nLine 3\n")
    create_file('common/test.md', "Common 1\nCommon 2\n")

    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => ['common/test.md']
    }])

    # Capture output
    out, _err = capture_io do
      build_all
    end

    # Verify line count is reported (includes spacing lines between sections)
    assert_match(/\d+ lines/, out, 'Should report line count')
  end

  def test_multiple_builds
    # Create files for two projects
    create_file('projects/project1/main.project.md', "# Project 1\n")
    create_file('projects/project2/main.project.md', "# Project 2\n")

    create_builds_config([
      {
        'name' => 'Project 1',
        'project' => 'projects/project1/main.project.md',
        'output' => 'output1/CLAUDE.local.md',
        'common' => []
      },
      {
        'name' => 'Project 2',
        'project' => 'projects/project2/main.project.md',
        'output' => 'output2/CLAUDE.local.md',
        'common' => []
      }
    ])

    # Run build
    build_all

    # Verify both outputs
    assert File.exist?('output1/CLAUDE.local.md'), 'First output should exist'
    assert File.exist?('output2/CLAUDE.local.md'), 'Second output should exist'
  end

  def test_skill_directory_structure_preserved
    # Create skill with subdirectories
    create_file('skills/test-skill/SKILL.md', "# Skill\n")
    create_file('skills/test-skill/examples/example.md', "# Example\n")
    create_file('projects/test-project/main.project.md', "# Test\n")

    create_builds_config([{
      'name' => 'Test',
      'project' => 'projects/test-project/main.project.md',
      'output' => 'output/CLAUDE.local.md',
      'common' => [],
      'skills' => ['test-skill']
    }])

    # Run build
    build_all

    # Verify structure is preserved
    assert File.exist?('output/.claude/skills/test-skill/SKILL.md'),
           'Skill root file should exist'
    assert File.exist?('output/.claude/skills/test-skill/examples/example.md'),
           'Skill subdirectory should be preserved'
  end
end
