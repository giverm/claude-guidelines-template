## Development Preferences

### When Writing Code

- Match existing patterns in the codebase before introducing new ones
- Keep it simple - don't over-engineer solutions
- Prefer explicit over clever
- Document complex business logic with comments
- **Don't make assumptions - ask questions when uncertain**

### Definition of Done

Before considering work complete:
- [ ] All tests pass (in CI/local environment)
- [ ] Linter clean
- [ ] Tests added for new functionality
- [ ] Code follows existing patterns in the codebase
- [ ] Self-review completed (`git diff --stat && git diff`)
