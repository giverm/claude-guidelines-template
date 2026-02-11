## YAGNI Principle (You Aren't Gonna Need It)

**Core philosophy:**
- If code isn't needed for the current story, skip it
- Ask: "Will we use this now?" not "Might we need this later?"
- Prefer simpler solutions over "defensive" code without clear use cases
- "Easy to add later" ≠ "should add now"

**Examples of what to skip:**
- Validation helper if no current validation needs
- Logging if no current debugging needs
- Abstraction if only one implementation exists
- Enum values for features not in any current story

**Decision framework when tempted to add infrastructure:**

1. Does the CURRENT story need this? (Not "will Story X need it")
2. Is it trivial to add later when needed?
3. Would deferring cause major refactoring?

**Generally defer if:**
- Infrastructure is for future stories
- Can be added incrementally
- No tests for the infrastructure (nothing uses it yet)
- Adds complexity without immediate value

**Consider adding now if:**
- Multiple stories in CURRENT PR need coordination
- Deferring would require touching many files later
- Pattern is well-established and simple

**Accepted tradeoff:** May need small refactoring in future stories. That's okay - we optimize for current needs, not hypothetical futures.
