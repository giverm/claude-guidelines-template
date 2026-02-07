# Claude Code Guidelines Template

A template repository for managing [Claude Code](https://claude.ai/code) guidelines across multiple projects using version control, DRY principles, and on-demand skills.

## Features

- **🔄 DRY Guidelines**: Write once in `common/`, reuse across projects
- **📦 Skills System**: Extract detailed workflows to on-demand skills (reduces baseline context)
- **🎯 Project Overrides**: Customize common patterns per project
- **🔗 Auto-linking**: Build script creates symlinks automatically
- **✅ Tested**: Comprehensive test suite ensures reliability
- **📝 YAML Config**: Easy-to-edit configuration

## Quick Start

### 1. Clone This Template

```bash
git clone https://github.com/YOUR-USERNAME/claude-guidelines-template.git claude-guidelines
cd claude-guidelines
```

### 2. Add Your First Project

```bash
# Create project directory
mkdir -p projects/my-project

# Create project file
cat > projects/my-project/main.project.md << 'EOF'
# My Project

## Tech Stack
- [Your stack here]

## Project Structure
- [Your structure]

## Key Patterns
- [Your patterns]
EOF
```

### 3. Configure Build

Edit `builds.yml`:

```yaml
builds:
  - name: My Project
    project: projects/my-project/main.project.md
    output: my-project/CLAUDE.local.md
    link_to: ~/Projects/my-project/CLAUDE.local.md  # Path to actual project
    common:
      - common/preferences.md
    skills: []  # Add skills as needed
```

### 4. Build

```bash
./build.rb
```

This generates:
- `my-project/CLAUDE.local.md` (in this repo)
- `my-project/.claude/skills/` (skill directories, if configured)
- Symlink at `~/Projects/my-project/CLAUDE.local.md` (points to generated file)
- Symlink at `~/Projects/my-project/.claude/skills/` (points to generated skills)

Claude Code will now use these guidelines when working in your project!

## Repository Structure

```
claude-guidelines/
├── common/                    # Shared guidelines (DRY)
│   ├── preferences.md        # Example: General preferences
│   └── _editing-instructions.md
├── projects/                  # Project-specific content
│   └── example-project/
│       └── main.project.md
├── skills/                    # On-demand skills (loaded when invoked)
│   └── example-skill/
│       └── SKILL.md
├── learnings/                 # Track what works (not in builds)
│   └── README.md
├── test/                      # Test suite
│   ├── build_test.rb
│   └── README.md
├── build.rb                   # Build script
├── builds.yml                 # Build configuration
├── Rakefile                   # Rake tasks
└── README.md                  # This file
```

## Core Concepts

### Common Guidelines

Files in `common/` are shared across all projects that include them:

```markdown
# common/preferences.md
When writing code:
- Match existing patterns
- Keep it simple
- Ask questions when uncertain
```

### Project-Specific Content

Each project has its own directory in `projects/`:

```markdown
# projects/my-app/main.project.md
# My App

## Tech Stack
- Rails 7, PostgreSQL, React

## Project Structure
- app/services/ - Business logic
- app/controllers/ - Keep thin
```

### Skills (On-Demand Loading)

Skills are detailed workflows loaded only when invoked with `/skill-name`:

```markdown
# skills/commit/SKILL.md
---
name: commit
description: Create well-formatted git commits
---

# Commit Guidelines
[Detailed commit message format, examples, checklist...]
```

**Benefits:**
- Reduces baseline context (skills not loaded unless needed)
- Detailed information available on-demand
- Modular and maintainable

### Override System

Projects can override common files with project-specific versions:

```
common/git-workflow.md          # Universal git patterns
projects/my-project/git-workflow.md  # Project-specific (overrides common/)
```

Hierarchical resolution:
1. Check `projects/my-project/git-workflow.md` (most specific)
2. Check parent directories
3. Fall back to `common/git-workflow.md`

## Usage

### Building

```bash
# Build all projects
./build.rb

# Via rake
rake build
```

### Testing

```bash
# Run tests
ruby test/build_test.rb

# Via rake
rake test

# Test + build
rake verify
```

### Adding a New Project

1. **Create project directory:**
   ```bash
   mkdir -p projects/my-project
   vim projects/my-project/main.project.md
   ```

2. **Add to `builds.yml`:**
   ```yaml
   - name: My Project
     project: projects/my-project/main.project.md
     output: my-project/CLAUDE.local.md
     link_to: ~/Projects/my-project/CLAUDE.local.md
     common:
       - common/preferences.md
     skills: []
   ```

3. **Build:**
   ```bash
   ./build.rb
   ```

### Creating a Skill

1. **Create skill directory:**
   ```bash
   mkdir -p skills/my-skill
   ```

2. **Create SKILL.md with frontmatter:**
   ```markdown
   ---
   name: my-skill
   description: What this skill does
   ---

   # My Skill

   Detailed instructions...
   ```

3. **Add to project in `builds.yml`:**
   ```yaml
   skills:
     - my-skill
   ```

4. **Rebuild:**
   ```bash
   ./build.rb
   ```

5. **Invoke in Claude:**
   ```
   /my-skill
   ```

### Creating Project Overrides

If a project needs different conventions:

```bash
# Create override (same filename as common file)
vim projects/my-project/git-workflow.md

# Rebuild - your version replaces common/git-workflow.md
./build.rb
```

## Best Practices

### What Goes in `common/`

- ✅ Patterns that apply to most projects
- ✅ Default workflows and preferences
- ✅ Universal best practices
- ✅ Framework-agnostic guidelines

### What Goes in `projects/`

- ✅ Tech stack specifics
- ✅ Project structure and navigation
- ✅ Domain-specific patterns
- ✅ Project-specific overrides

### What Goes in `skills/`

- ✅ Detailed workflows (>50 lines)
- ✅ Task-specific instructions
- ✅ Reference material used occasionally
- ✅ Complex processes with multiple steps

### When to Use Skills

**Extract to skill when:**
- Content is >50-100 lines
- Only needed for specific tasks
- Used occasionally, not constantly
- Detailed step-by-step instructions

**Keep in main file when:**
- Concise reference information
- Needed frequently during development
- Core patterns you want always visible

## Examples

See the `projects/example-project/` directory for a complete example showing:
- Project structure
- Common file usage
- Skill references
- Override patterns

## Contributing

This is a template - customize it for your needs! Some ideas:

- Add more common guidelines for your tech stack
- Create skills for your workflows
- Add project-specific overrides
- Extend the test suite
- Improve documentation

## Future Directions

Potential enhancements we'd like to explore:

### Skill Management
- **Central skill repository**: Pull common skills from a shared registry
- **Skill versioning**: Track skill versions, allow pinning to specific versions
- **Skill dependencies**: Skills that reference or depend on other skills

### Developer Experience
- **Interactive setup wizard**: Guided initial configuration (`./build.rb --init`)
- **Guideline linting**: Validate guideline format, check for common issues, verify skill references exist
- **Git hooks**: Auto-rebuild on commit, validate changes pre-commit

### Advanced Features
- **Multi-project diffs**: Compare guidelines across projects to find inconsistencies
- **Conditional includes**: Include common files based on tech stack detection
- **CI/CD examples**: GitHub Actions, GitLab CI templates for automated validation
- **Migration tools**: Import existing CLAUDE.md files into template structure

**Have ideas?** Open an issue or PR! We're particularly interested in:
- Real-world usage patterns and learnings
- Skills that could be shared broadly
- Improvements to the build system
- Better testing approaches

## License

MIT License - See LICENSE file

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Skills Documentation](https://code.claude.com/docs/en/skills)

---

**Happy coding with Claude! 🚀**
