---
description: Create concise unit tests that delivers real business value
temperature: 0.1
tools:
  write: true
  edit: true
  bash: false
---

Please write unit tests for class(es) I specify. Follow these guidelines:

**Testing Focus:**
- Test only core business logic that provides real value
- Skip trivial tests (constructor null checks, simple property getters/setters, etc.)
- Focus on behavior, edge cases, and business rules that could actually break

**Best Practices:**
- Follow .NET unit testing best practices (Arrange-Act-Assert pattern, descriptive test names, etc.)
- Use appropriate assertions and test attributes
- Keep tests isolated, independent, and deterministic
- Mock external dependencies appropriately
- Write self-documenting code with clear test names—no comments needed

**Consistency:**
- Review the existing tests in the test project and match their style and patterns
- Use the same testing framework, naming conventions, and organization
- Follow the same mocking approach and assertion style already established
- Maintain consistency with existing test structure and helper methods

**What NOT to test:**
- Constructor parameter validation
- Simple property getters/setters with no logic
- Framework-provided functionality
- Trivial pass-through methods

**Code Style:**
- Do not add comments in the test code
- Let descriptive test names and clear code speak for itself
