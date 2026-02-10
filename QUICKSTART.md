# Quick Start Guide

Get up and running in 5 minutes.

## 1. Clone & Setup

```bash
git clone https://github.com/YOUR-USERNAME/claude-guidelines-template.git my-guidelines
cd my-guidelines
```

## 2. Remove Example

```bash
rm -rf projects/example-project generated/example-project/
```

## 3. Create Your First Project

```bash
# Create directory
mkdir -p projects/my-app

# Create project file
cat > projects/my-app/main.project.md << 'EOF'
# My App

## Tech Stack
- Ruby on Rails
- PostgreSQL
- React

## Project Structure
- app/models/ - Data models
- app/controllers/ - API endpoints
- app/services/ - Business logic

## Key Patterns
- Keep controllers thin
- Business logic in services
- Test everything
EOF
```

## 4. Configure Build

Edit `builds.yml`:

```yaml
builds:
  - name: My App
    project: projects/my-app/main.project.md
    output: generated/my-app/guidelines.md
    link_to: ~/Projects/my-app/CLAUDE.local.md  # ← Change this path
    common:
      - common/preferences.md
    skills: []
```

## 5. Build

```bash
./build.rb
```

✅ Done! Your guidelines are now active in `~/Projects/my-app/`

## Next Steps

### Add More Projects

Repeat steps 3-5 for each project.

### Create Common Guidelines

Add files to `common/` that apply to multiple projects:

```bash
cat > common/git-workflow.md << 'EOF'
## Git Workflow

- Create feature branches
- Keep commits atomic
- Write clear commit messages
EOF
```

Then add to your project's `common:` list in `builds.yml`.

### Create Skills

For detailed workflows (>50 lines), create skills:

```bash
mkdir -p skills/commit
cat > skills/commit/SKILL.md << 'EOF'
---
name: commit
description: Create well-formatted commits
---

# Commit Guidelines

[Detailed instructions...]
EOF
```

Add to project's `skills:` list and invoke with `/commit`.

### Use Overrides

If a project needs different conventions:

```bash
# Create override in project directory
vim projects/my-app/git-workflow.md

# It replaces common/git-workflow.md for this project
./build.rb
```

## Tips

- **Common files:** Patterns used across projects
- **Skills:** Detailed workflows used occasionally
- **Overrides:** Project-specific versions of common files
- **Learnings:** Track what works (in `learnings/`, not in builds)

## Help

- Full docs: `README.md`
- Test suite: `rake test`
- Questions: Open an issue

**Happy coding with Claude! 🚀**
