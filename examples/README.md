# Examples Directory

This directory contains **real-world examples** demonstrating how to structure guidelines and skills for your projects.

## What's Included

### Common Guidelines (`common/`)

**Purpose:** Universal patterns shared across projects, kept in main guidelines file (always loaded).

- **`git-workflow.md`** - Branching, PR strategy, and overall git workflow
- **`yagni-principle.md`** - Decision framework for avoiding over-engineering

**Key characteristic:** These are **concise** and reference skills for details.

### Skills (`skills/`)

**Purpose:** Detailed workflows loaded on-demand with `/skill-name` (reduces baseline context).

- **`commit/`** - Comprehensive commit guidelines with checklists, patterns, and examples

**Key characteristic:** These are **comprehensive** and include step-by-step details.

---

## How They Work Together

### The Value Proposition

**Problem:** If you put everything in common guidelines, the file becomes huge and bloats every session's context.

**Solution:** Keep common files concise, extract details to skills.

### Real Example: Git Workflow + Commit Skill

**In `common/git-workflow.md` (always loaded):**
```markdown
### Commit Messages

**Quick guidelines:**
- Keep first line under 72 characters
- Use imperative mood ("Add feature" not "Added feature")
- Include "why" not just "what"
- Run linter, tests, and review changes before committing

**For detailed commit guidelines** → Use the `/commit` skill
```

**In `skills/commit/SKILL.md` (loaded on-demand):**
- 500 lines of comprehensive guidance
- Pre-commit checklist
- Message format templates
- Common patterns (features, bugs, refactoring)
- Before/after examples
- Special cases and tips

### Usage Pattern

**Developer workflow:**
1. **Reading guidelines:** Sees concise git workflow overview
2. **Ready to commit:** Invokes `/commit` to load full checklist
3. **After commit:** Skill context disappears from next session

**Result:**
- Developer gets details when needed
- Guidelines stay lean and scannable
- Context window used efficiently

---

## Adapting These Examples

### For Your Projects

1. **Copy examples you want:**
   ```bash
   cp examples/common/git-workflow.md common/
   cp -r examples/skills/commit skills/
   ```

2. **Customize for your team:**
   - Update branch naming conventions
   - Add your issue tracker format
   - Adjust commit patterns to match your style
   - Add/remove language-specific commands

3. **Configure in `builds.yml`:**
   ```yaml
   common:
     - common/git-workflow.md
   skills:
     - commit
   ```

### Creating Your Own Examples

**Good candidates for common/ files:**
- High-level workflows (git, testing, deployment)
- Decision frameworks (YAGNI, when to refactor)
- Universal preferences (code style, communication)
- Project structure and navigation

**Good candidates for skills/:**
- Detailed checklists (commit, review, deploy)
- Multi-step processes (debugging, troubleshooting)
- Reference material (API patterns, database schemas)
- Workflow-specific guidance (>100 lines)

**Rule of thumb:** If it's >50-100 lines and used occasionally → extract to skill

---

## Benefits Demonstrated

### Context Efficiency

**Without skills:**
- `git-workflow.md`: 300 lines (always loaded)
- Every session pays the cost

**With skills:**
- `git-workflow.md`: 130 lines (always loaded)
- `commit` skill: 500 lines (loaded only when invoked)
- **Savings:** 170 lines of baseline context

### Maintainability

**Modular updates:**
- Update git workflow → change one section
- Update commit details → change skill file
- No duplication or sync issues

**Clear ownership:**
- Common files: Essential knowledge
- Skills: Detailed how-to guides

### Discoverability

**Developers know where to look:**
- Guidelines: "What's the overall process?"
- Skills: "What's the detailed checklist?"

---

## Template vs Personal Repo

**These examples are generic** - suitable for any project or team.

**In your personal instance,** you might have:
- Company-specific workflow patterns
- Team conventions and standards
- Project-specific skills
- Private process documentation

**That's the power of this system:**
- Template provides starting patterns
- You customize and extend for your needs
- Share back generic improvements to template

---

## Questions?

- See main `README.md` for full system documentation
- See `QUICKSTART.md` for setup instructions
- Check commit history to see how examples evolved

**Ready to use these?** Copy to your `common/` and `skills/` directories and customize!
