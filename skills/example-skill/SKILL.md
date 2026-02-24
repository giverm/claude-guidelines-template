# Example Skill

**Purpose:** This is an example skill demonstrating the format and structure.

**Replace this with your actual skill content.**

## When to Use This Skill

Use `/example-skill` when:
- You want to see how skills are structured
- You're creating your own skill

## Instructions

Skills contain detailed, step-by-step instructions that are loaded on-demand when invoked with `/skill-name`.

### Step 1: Create Skill Directory

```bash
mkdir -p skills/my-skill
```

### Step 2: Create meta.yml (Optional)

Store metadata separately so it doesn't consume context tokens when the skill is loaded:

```yaml
name: my-skill
description: Brief description
version: 1.0.0
category: workflow|review|git|testing
```

The build script reads `meta.yml` to display version info during builds.

### Step 3: Write SKILL.md

Write clear, actionable instructions:
- Use headings to organize
- Include examples
- Provide context
- Add checklists

### Step 4: Add to Build Config

In `builds.yml`:
```yaml
skills:
  - my-skill
```

## Example

```markdown
# Commit Guidelines

Before committing:
- [ ] Run tests
- [ ] Run linter
- [ ] Review diff

Format:
- Title <72 characters
- Body explains why
```

## Tips

**Skills are great for:**
- Workflows >50 lines
- Detailed checklists
- Reference material
- Task-specific instructions

**Keep in main guidelines:**
- Frequently-needed info
- Concise patterns
- Core principles
