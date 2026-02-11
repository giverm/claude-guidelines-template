## Git Workflow

**Note:** This is an example showing common git patterns. Adapt branch naming, commit conventions, and PR strategies to match your team's practices.

### Starting New Work

**ALWAYS create a feature branch before making any code changes:**

1. **Checkout main and pull latest**:
   ```bash
   git checkout main
   git pull origin main
   ```
2. **Create feature branch** using your team's naming convention:
   - `feature/add-user-auth`
   - `fix/login-timeout`
   - `docs/update-readme`
3. **Verify you're on the right branch**:
   ```bash
   git branch --show-current
   ```
4. **Then begin implementation**

**Why**: Working on the wrong branch requires stashing and branch switching. Creating the branch first prevents this.

### Commit Messages

**Quick guidelines:**
- Keep first line under 72 characters
- Use imperative mood ("Add feature" not "Added feature")
- Include "why" not just "what"
- Run linter, tests, and review changes before committing

**For detailed commit guidelines**, including:
- Pre-commit checklist
- Message format and examples
- Common patterns (features, bugs, refactoring)
- What to include/avoid

**→ Use the `/commit` skill** for comprehensive commit guidance.

### Pull Request Size & Strategy

**General principle:** Optimize for reviewability. PRs should be focused, manageable units of review.

**Target size:** ~200-500 lines is ideal for thorough review
- Smaller PRs get faster, better reviews
- Larger PRs are harder to review thoroughly
- Consider splitting if approaching 1000+ lines

**When to split PRs:**
- Exceeds comfortable review size
- Has distinct phases (infrastructure → usage)
- Mixes concerns (database + business logic + UI)
- Has natural "reviewable separately" boundaries
- Would take >30 minutes to review thoroughly

**Splitting strategies:**
1. **Foundation → Implementation** (schema → business logic)
2. **Core → Edge Cases** (happy path → error handling)
3. **Backend → Frontend** (API → UI)
4. **By Component** (service A → service B)

**Stacking PRs:**
- Each PR should be independently reviewable
- Each PR should pass tests
- Use feature flags if functionality isn't complete
- Document dependencies in PR descriptions

### Branch Management

**Delete after merge:**
```bash
git branch -d feature/my-feature  # Local
git push origin --delete feature/my-feature  # Remote
```

**Keep branches up to date:**
```bash
# Rebase on main to avoid merge commits
git fetch origin
git rebase origin/main

# Or merge if your team prefers
git merge origin/main
```

### Common Workflows

**Quick fix:**
```bash
git checkout main && git pull
git checkout -b fix/issue-description
# make changes
git add . && git commit -m "Fix issue description"
git push -u origin fix/issue-description
```

**Feature with multiple commits:**
```bash
git checkout main && git pull
git checkout -b feature/new-feature
# make changes, commit as you go
git commit -m "Add foundation for feature"
# more changes
git commit -m "Add tests and edge cases"
git push -u origin feature/new-feature
```

**Address PR feedback:**
```bash
# make requested changes
git add .
git commit -m "Address PR feedback: refactor validation"
git push
```
