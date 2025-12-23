# Code Review Checklist

**Reviewer**: [Your Name]
**Date**: [YYYY-MM-DD]
**PR/Branch**: [Link to PR or branch name]
**Author**: [Author Name]

---

## Pre-Review

- [ ] PR description is clear and complete
- [ ] Changes are appropriately sized (not too large)
- [ ] All CI/CD checks passing
- [ ] Tests included with changes
- [ ] Documentation updated if needed

---

## Code Quality

### Clarity & Readability
- [ ] Code is easy to understand
- [ ] Variable and function names are descriptive
- [ ] Complex logic has explanatory comments
- [ ] No unnecessary complexity
- [ ] Consistent code style

### Smart Contract Specific (Clarity)
- [ ] Function names follow conventions
- [ ] Error codes are documented
- [ ] Public functions have clear purposes
- [ ] Read-only vs public is appropriate
- [ ] Constants used instead of magic numbers

---

## Functionality

### Correctness
- [ ] Code does what it's supposed to do
- [ ] Edge cases are handled
- [ ] Error conditions are caught
- [ ] Return values are correct
- [ ] Logic flow is sound

### Testing
- [ ] Unit tests cover new code
- [ ] Integration tests included if needed
- [ ] Tests actually test the functionality
- [ ] Test names are descriptive
- [ ] Happy path AND error cases tested

---

## Security

### Smart Contract Security
- [ ] No re-entrancy vulnerabilities
- [ ] Integer overflow/underflow protected
- [ ] Access control properly implemented
- [ ] No unbounded loops
- [ ] External calls are safe

### Input Validation
- [ ] All inputs are validated
- [ ] Bounds are checked
- [ ] Type safety enforced
- [ ] Malicious inputs handled

### Authentication & Authorization
- [ ] tx-sender checks where needed
- [ ] Contract-caller vs tx-sender used correctly
- [ ] Admin functions protected
- [ ] No privilege escalation possible

---

## Performance

- [ ] No unnecessary computations
- [ ] Efficient data structures used
- [ ] Database queries optimized (if applicable)
- [ ] Gas usage reasonable (for blockchain)
- [ ] No performance regressions

---

## Documentation

- [ ] Code comments where needed
- [ ] Public API documented
- [ ] README updated if needed
- [ ] CHANGELOG updated
- [ ] Breaking changes noted

---

## Best Practices

### Clarity Smart Contracts
- [ ] Follows SIP-010 if applicable
- [ ] Uses traits appropriately
- [ ] Error handling consistent
- [ ] Map/variable declarations clear
- [ ] Functions are focused (single responsibility)

### General
- [ ] DRY principle followed (no duplication)
- [ ] SOLID principles applied
- [ ] Proper error handling
- [ ] No hardcoded values
- [ ] Configuration externalized

---

## Questions & Concerns

### Questions for Author
1. [Question about implementation choice]
2. [Question about edge case]

### Potential Issues
1. [Concern about security/performance/etc]
2. [Suggestion for improvement]

### Suggestions
1. [Optional improvement]
2. [Code style suggestion]

---

## Review Decision

**Status**: [Approve / Request Changes / Comment]

### Summary
[Brief summary of your review]

### Required Changes (if any)
1. [Critical change needed]
2. [Important fix required]

### Optional Improvements
1. [Nice-to-have enhancement]
2. [Code style suggestion]

---

## Approval Checklist

Before approving, confirm:

- [ ] All critical issues addressed
- [ ] Security concerns resolved
- [ ] Tests are comprehensive
- [ ] Documentation is complete
- [ ] No regressions introduced
- [ ] Code style is consistent
- [ ] Author questions answered

---

**Review Notes**:
[Additional context, discussion points, or follow-up items]

---

*Use this checklist to ensure thorough, consistent code reviews.*
