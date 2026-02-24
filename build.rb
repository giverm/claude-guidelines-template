#!/usr/bin/env ruby
# frozen_string_literal: true

# Build script to combine common guidelines with project-specific content
# Usage: ./build.rb

require 'fileutils'
require 'pathname'
require 'yaml'

# Load build configuration from YAML file
def load_builds
  config_path = Pathname.new('builds.yml')
  unless config_path.exist?
    warn "⚠️  Configuration file not found: builds.yml"
    return []
  end

  yaml = YAML.safe_load_file(config_path, permitted_classes: [], permitted_symbols: [], aliases: false)
  return [] unless yaml && yaml['builds']

  yaml['builds'].map { |build| build.transform_keys(&:to_sym) }
end

# Only load builds if not in test mode
unless defined?(Minitest)
  BUILDS = load_builds.freeze
end

def build_file(config)
  content_parts = []

  # Add editing instructions header (if exists)
  header_path = Pathname.new("common/_editing-instructions.md")
  if header_path.exist?
    content_parts << header_path.read
    content_parts << "\n"
  end

  # Read project-specific content
  project_path = Pathname.new(config[:project])
  unless project_path.exist?
    warn "⚠️  Project file not found: #{config[:project]}"
    return false
  end

  content_parts << project_path.read

  # Determine project directory for overrides
  project_dir = project_path.dirname

  # Add common sections (with hierarchical override support)
  config[:common].each do |common_file|
    common_filename = Pathname.new(common_file).basename

    # Check for override in project directory hierarchy (child first, then parents)
    file_to_use = nil
    current_dir = project_dir
    projects_root = Pathname.new("projects")

    # Walk up the directory tree looking for overrides
    while current_dir.to_s.start_with?(projects_root.to_s)
      override_candidate = current_dir.join(common_filename)
      if override_candidate.exist?
        file_to_use = override_candidate
        break
      end
      break if current_dir == projects_root
      current_dir = current_dir.parent
    end

    # Fall back to common file if no override found
    file_to_use ||= Pathname.new(common_file)

    unless file_to_use.exist?
      warn "⚠️  File not found: #{file_to_use}"
      next
    end

    content_parts << "\n"  # Add spacing between sections
    content_parts << file_to_use.read
  end

  # Ensure output directory exists
  output_path = Pathname.new(config[:output])
  FileUtils.mkdir_p(output_path.dirname)

  # Write combined content
  output_path.write(content_parts.join)

  # Calculate stats
  line_count = content_parts.join.lines.count

  puts "✓ Built #{config[:name]}"
  puts "  → #{config[:output]} (#{line_count} lines)"

  # Copy skills if specified
  copy_skills(config, project_dir, output_path) if config[:skills]

  # Create symlinks if link_to is specified
  if config[:link_to]
    create_symlink(output_path, config[:link_to])

    # Symlink .claude directory or skills subdirectory
    claude_dir = output_path.dirname.join('.claude')
    if claude_dir.exist?
      target_claude_base = Pathname.new(config[:link_to]).expand_path.dirname.join('.claude')

      # If target .claude doesn't exist or is a symlink, link the whole directory
      if !target_claude_base.exist? || target_claude_base.symlink?
        create_symlink(claude_dir, target_claude_base)
      else
        # If target .claude exists with other content, just link skills subdirectory
        claude_skills = claude_dir.join('skills')
        target_skills = target_claude_base.join('skills')
        if claude_skills.exist?
          create_symlink(claude_skills, target_skills)
        end
      end
    end
  end

  true
end

def copy_skills(config, project_dir, output_path)
  return unless config[:skills]

  # Skills output directory: <output_dir>/.claude/skills/
  skills_output_dir = output_path.dirname.join('.claude', 'skills')
  FileUtils.mkdir_p(skills_output_dir)

  # Clean up skills not in config (remove skills that were removed from builds.yml)
  if skills_output_dir.exist?
    existing_skills = skills_output_dir.children.select(&:directory?).map { |d| d.basename.to_s }
    configured_skills = config[:skills].map(&:to_s)
    skills_to_remove = existing_skills - configured_skills

    skills_to_remove.each do |skill_name|
      skill_path = skills_output_dir.join(skill_name)
      FileUtils.rm_rf(skill_path)
      puts "  → Removed: #{skill_name} (not in config)"
    end
  end

  projects_root = Pathname.new("projects")
  common_skills_dir = Pathname.new("skills")

  config[:skills].each do |skill_name|
    # Find skill using hierarchical override (project → parent → common)
    skill_source = nil
    current_dir = project_dir

    # Walk up project directory tree
    while current_dir.to_s.start_with?(projects_root.to_s)
      candidate = current_dir.join('skills', skill_name)
      if candidate.directory?
        skill_source = candidate
        break
      end
      break if current_dir == projects_root
      current_dir = current_dir.parent
    end

    # Fall back to common skills
    skill_source ||= common_skills_dir.join(skill_name)

    unless skill_source.exist?
      warn "  ⚠️  Skill not found: #{skill_name}"
      next
    end

    # Copy skill directory to output
    skill_dest = skills_output_dir.join(skill_name)
    FileUtils.rm_rf(skill_dest) if skill_dest.exist?
    FileUtils.cp_r(skill_source, skill_dest)

    # Read meta.yml for display if it exists
    meta_path = skill_source.join('meta.yml')
    if meta_path.exist?
      meta = YAML.safe_load_file(meta_path, permitted_classes: [], permitted_symbols: [], aliases: false)
      puts "  → Skill: #{skill_name} v#{meta['version']}"
    else
      puts "  → Skill: #{skill_name}"
    end
  end
end

def create_symlink(source, target_path)
  # Expand ~ to full home path
  target = Pathname.new(target_path).expand_path
  source_abs = source.expand_path

  # Check if target directory exists
  unless target.dirname.exist?
    puts "  ⚠️  Skipping symlink: Target directory does not exist: #{target.dirname}"
    return
  end

  # Remove existing symlink or file if it exists
  if target.symlink?
    target.unlink
  elsif target.exist?
    puts "  ⚠️  Skipping symlink: Target exists and is not a symlink: #{target}"
    return
  end

  # Create symlink
  target.make_symlink(source_abs)
  puts "  → Linked to #{target}"
rescue StandardError => e
  puts "  ⚠️  Failed to create symlink: #{e.message}"
end

def clean_orphaned_builds(builds)
  puts "Checking for orphaned build outputs..."

  # Get all configured outputs
  configured_outputs = builds.map { |b| Pathname.new(b[:output]) }
  configured_claude_dirs = configured_outputs.map { |p| p.dirname.join('.claude') }

  # Find all existing CLAUDE.local.md files and .claude directories
  existing_outputs = Pathname.glob('**/CLAUDE.local.md')
  existing_claude_dirs = Pathname.glob('**/.claude').select(&:directory?)

  # Remove outputs not in config
  orphaned_outputs = existing_outputs - configured_outputs
  orphaned_outputs.each do |orphan|
    puts "  → Removing orphaned: #{orphan}"
    FileUtils.rm_f(orphan)
  end

  # Remove .claude directories not in config (but preserve if they have non-skill content)
  orphaned_claude_dirs = existing_claude_dirs - configured_claude_dirs
  orphaned_claude_dirs.each do |orphan|
    # Only remove if it only contains skills (safe to remove generated content)
    children = orphan.children.map { |c| c.basename.to_s }
    if children.empty? || children == ['skills']
      puts "  → Removing orphaned .claude: #{orphan}"
      FileUtils.rm_rf(orphan)
    else
      puts "  ⚠️  Skipping .claude with user content: #{orphan}"
    end
  end

  puts unless orphaned_outputs.empty? && orphaned_claude_dirs.empty?
end

def build_all
  puts "Building CLAUDE.local.md files..."
  puts

  builds = defined?(BUILDS) ? BUILDS : load_builds

  # Clean up orphaned builds first
  clean_orphaned_builds(builds)

  success_count = 0
  builds.each do |config|
    success_count += 1 if build_file(config)
  end

  puts
  puts "#{success_count}/#{builds.length} files built successfully"

  success_count == builds.length
end

# Main execution
if __FILE__ == $PROGRAM_NAME
  exit(build_all ? 0 : 1)
end
