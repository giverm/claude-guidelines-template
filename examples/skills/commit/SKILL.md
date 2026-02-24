# Commit: Git Commit Guidelines

**Purpose:** Comprehensive guide for creating clear, informative git commits.

**When to use this skill:** Invoke `/commit` when you're ready to create a commit and want the full checklist and formatting guidelines.

---

## Pre-commit Checklist

**ALWAYS complete these steps before committing:**

### 1. Run linter/formatter
```bash
# Examples for different languages
npm run lint          # JavaScript/TypeScript
rubocop -A            # Ruby
black . && isort .    # Python
cargo fmt             # Rust
gofmt -w .            # Go
```

### 2. Run tests
```bash
# Examples
npm test              # JavaScript
pytest                # Python
cargo test            # Rust
bundle exec rspec     # Ruby
go test ./...         # Go
```

### 3. Run migrations (if applicable)
```bash
# Examples
rails db:migrate      # Rails
alembic upgrade head  # Python/Alembic
npm run migrate       # Node
```

### 4. Review your changes
```bash
git diff --stat       # See which files changed
git diff              # See actual changes
```

**Look for:**
- Debug statements or console.logs to remove
- Commented-out code to clean up
- TODOs that should be addressed now
- Unintended changes that snuck in

### 5. Stage and commit
```bash
git add <files>       # Stage specific files
# or
git add -A            # Stage all changes

# Then commit (see formats below)
```

---

## Commit Message Format

### Standard Structure

```
<Title: concise summary under 72 characters>

<Blank line>

<Detailed description: what changed and WHY>
<Technical approach if non-obvious>
<Impact, related issues, or future work>
```

### Title Guidelines

**Keep under 72 characters** so it displays properly in git tools.

**Use imperative mood:**
- ✅ "Add feature"
- ✅ "Fix bug"
- ✅ "Refactor module"
- ❌ "Added feature"
- ❌ "Adds feature"
- ❌ "Adding feature"

**Be specific but concise:**
- ✅ "Add user authentication with OAuth2"
- ✅ "Fix race condition in payment processing"
- ❌ "Add feature"
- ❌ "Fix bug"
- ❌ "Update code"

### Body Guidelines

**Explain the WHY, not just the WHAT:**
- The code shows *what* changed
- The commit message should explain *why* it changed
- Include context that isn't obvious from the code

**Include:**
- Motivation for the change
- Approach taken (if not obvious)
- Tradeoffs considered
- Related issues or future work enabled
- Breaking changes or migration notes

**Avoid:**
- Line counts ("Changes 150 lines")
- Test counts ("Adds 25 tests")
- Listing every file changed (git shows this)

---

## Using Heredoc for Multi-line Messages

**Always use heredoc** to avoid shell escaping issues:

```bash
git commit -m "$(cat <<'EOF'
Add caching layer for API responses

Implements Redis-based caching to reduce database load during
high-traffic periods. Cache invalidation happens on write
operations to maintain data consistency.

Reduces average response time from 200ms to 50ms.
EOF
)"
```

**Why heredoc:**
- Preserves line breaks and formatting
- No need to escape quotes or special characters
- Clear, readable multi-line messages
- Works consistently across shells

---

## Common Commit Patterns

### Feature Addition

```
Add [feature name]

[What it does and why it's needed]
[Technical approach if non-obvious]
[What this enables or impacts]
```

**Example:**
```
Add user notification system

Implements email and in-app notifications using background job
queue. Uses template system for easy customization across
notification types.

This provides the foundation for:
- Password reset notifications
- Activity alerts
- Scheduled report delivery

Uses Sidekiq for job processing with exponential backoff retry.
```

### Bug Fix

```
Fix [concise problem description]

[What was wrong - the symptoms]
[Root cause - why it was happening]
[How the fix addresses it]
[Why this approach over alternatives]
```

**Example:**
```
Fix race condition in payment processing

Multiple simultaneous payment attempts for the same order could
result in duplicate charges. Race condition occurred because
payment status check and charge creation weren't atomic.

Added database-level pessimistic locking around payment flow.
Chose pessimistic over optimistic locking to ensure zero chance
of duplicate charges, accepting slight performance tradeoff.
```

### Refactoring

```
Refactor [component] to [improvement]

[Why refactoring was needed]
[What changed architecturally]
[Benefits gained]
```

**Example:**
```
Refactor authentication to use middleware pattern

Auth checks were scattered throughout 15+ controller methods,
making security updates risky and creating duplication.

Consolidated into reusable middleware that runs before controller
actions. Reduces code duplication from 200+ lines to single
50-line middleware module.

Benefits:
- Single place to update auth logic
- Easier to add new auth requirements
- Simpler to test in isolation
```

### Infrastructure/Configuration

```
Add [infrastructure component]

[What it provides]
[Configuration details]
[What this enables for future work]
```

**Example:**
```
Add database connection pooling

Implements connection pooling with pg-pool to handle increased
concurrent requests. Configured with:
- Pool size: 20 connections
- Idle timeout: 30 seconds
- Connection timeout: 5 seconds

This supports the load balancer deployment planned next sprint
and resolves connection exhaustion issues during traffic spikes.
```

### Documentation

```
Update [docs] to [improvement]

[What was unclear or missing]
[What's now documented]
[Who benefits]
```

**Example:**
```
Update API documentation with authentication flow

Previous docs didn't explain OAuth2 flow or token refresh.
Added sequence diagrams and example requests for:
- Initial authentication
- Token refresh
- Error handling

Reduces support tickets from API consumers by providing
clear integration examples.
```

---

## What NOT to Include

❌ **Avoid these in commits:**

**Metrics/Counts:**
- "Changes 150 lines in 10 files"
- "Adds 25 tests"
- "Touches 5 components"

**Vague descriptions:**
- "Fix bug"
- "Update code"
- "Refactor"
- "Address feedback"

**Implementation minutiae in title:**
- ❌ "Refactor UserAuth to extract validateToken into separate module"
- ✅ "Refactor authentication for better testability"

**Multiple concerns in one commit:**
- If your commit message needs "and" multiple times, consider splitting

---

## Special Cases

### Merge Commits

**Most merge commits auto-generate fine.** For manual merge commits:

```
Merge feature-x into main

Resolves conflicts in:
- config/settings.yml (kept feature-x version)
- src/api/routes.js (combined both changes)

All tests passing after conflict resolution.
```

### Revert Commits

```
Revert "Add feature X"

This reverts commit abc123.

Reason: Feature X causes performance degradation in production.
Response time increased from 100ms to 2s under load.

Will re-implement with proper caching in follow-up PR.
```

### Hotfix Commits

```
Hotfix: Stop payment processing immediately

Critical bug allowing negative payment amounts. Disabling payment
endpoint until validation fix is deployed.

Temporary measure - proper fix in PR #456.
```

---

## Commit Strategy Considerations

### Commit Frequency

**Commit when:**
- You've completed a logical unit of work
- All tests pass
- Code is in reviewable state

**Don't commit:**
- Work-in-progress that breaks tests (use git stash instead)
- Multiple unrelated changes together
- Before running linter/formatter

### Commit Size

**Good commit sizes:**
- **Small commits** (~50-200 lines): Easy to review, easy to revert
- **Medium commits** (~200-500 lines): One complete feature/fix
- **Large commits** (500+ lines): Only when truly necessary (schema changes, large refactors)

**If your commit is large:**
- Can you split it into foundation → implementation?
- Can you separate refactoring from new feature?
- Would reviewers prefer multiple focused commits?

### When to Amend

**Use `git commit --amend` when:**
- You caught a typo in the last commit
- You forgot to add a file
- You want to improve the commit message
- **Only if you haven't pushed yet**

**Don't amend if:**
- You've already pushed (others may have pulled)
- The change is a different concern (make new commit instead)
- You're addressing code review feedback (new commit shows changes)

---

## Integration with Git Workflow

**Standard workflow:**

1. **Branch:** Create feature branch from main
2. **Develop:** Make changes iteratively
3. **Pre-commit:** Run checklist (invoke `/commit` for reminder)
4. **Commit:** Create clear commit message
5. **Push:** Push to remote
6. **PR:** Create pull request

**Multiple commits:**
- Each commit should leave codebase in working state
- Each commit should pass tests independently
- Commits tell a story of how the feature was built

**After code review:**
- Make requested changes
- Create new commit for review changes (easier to review)
- Don't amend previous commits (makes review harder)

---

## Tips for Great Commits

### Think About Your Audience

**Your commit message readers:**
- Reviewers trying to understand your PR
- Future developers debugging this code
- Yourself in 6 months

**Ask yourself:**
- What would I want to know if reviewing this?
- What context isn't obvious from the code?
- Why did we choose this approach?

### When Writing Commit Messages

**Take your time:**
- Commit message is permanent
- Good messages save hours of confusion later
- Worth spending 2-3 minutes to write clearly

**Be honest about tradeoffs:**
- "Quick fix for hotfix, needs proper solution later"
- "Temporary workaround for third-party API bug"
- "Chose simplicity over performance here"

**Connect to bigger picture:**
- "This enables feature Y planned next sprint"
- "Removes blocker for team X"
- "First step toward migrating to new architecture"

---

## Examples: Before & After

### ❌ Bad Commit

```
Update auth

Changed how auth works.
```

**Problems:**
- Vague title
- No explanation of what changed or why
- Past tense instead of imperative
- No context for future readers

### ✅ Good Commit

```
Refactor authentication to support multiple providers

Previous auth system was hardcoded to single OAuth provider.
Refactored to provider abstraction that allows plugging in
different auth backends (OAuth, SAML, LDAP).

This enables:
- SSO integration for enterprise customers
- Testing with local auth in development
- Supporting multiple OAuth providers

Chose strategy pattern for provider selection. Each provider
implements common interface, keeping controller logic simple.
```

**Why it's good:**
- Clear, specific title
- Explains what changed and why
- Shows future benefits
- Explains technical approach
- Imperative mood

---

## Checklist Summary

Before committing, verify:

- [ ] Linter/formatter run and passing
- [ ] Tests run and passing
- [ ] Migrations run (if applicable)
- [ ] Reviewed diff for unintended changes
- [ ] Commit title under 72 characters
- [ ] Commit title uses imperative mood
- [ ] Commit body explains WHY, not just WHAT
- [ ] Referenced related issues if applicable
- [ ] No debug statements or TODOs left behind
- [ ] Each commit is focused on one logical change

**Then create your commit with confidence!**
