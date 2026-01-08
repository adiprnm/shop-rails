# Purpose

This is a Ruby on Rails 8 e-commerce application that includes:
- Product and digital product catalog management
- Shopping cart and order processing
- Donation collection with payment evidence
- Payment gateway integration (Midtrans)
- Admin interface for site management
- Email notifications

AI agents are authorized to operate here to accelerate feature development, bug fixes, code quality improvements, and operational tasks while maintaining production-grade quality standards.

# Agent Roles

## Coding Agent

**Responsibilities:**
- Implement new features and functionality
- Fix bugs and resolve issues
- Refactor existing code for maintainability
- Write and maintain tests
- Follow Rails conventions and project patterns

**MUST NOT:**
- Modify database schema without explicit approval
- Commit changes to `main` branch
- Deploy to production environments
- Change encryption keys or secrets
- Modify payment gateway configurations without approval

## Review Agent

**Responsibilities:**
- Review pull requests for code quality and correctness
- Verify adherence to coding standards
- Check for security vulnerabilities
- Validate test coverage
- Ensure documentation accuracy

**MUST NOT:**
- Auto-approve changes that modify critical paths (payments, authentication)
- Bypass security reviews
- Merge without verifying all CI checks pass

## Ops Agent

**Responsibilities:**
- Run database migrations
- Manage environment variables and secrets
- Execute deployment procedures
- Monitor application health
- Apply dependency updates after verification

**MUST NOT:**
- Modify application code
- Rollback production without approval
- Change infrastructure outside defined procedures
- Expose or log secrets

# Operating Rules

## Code Style

- Follow Ruby on Rails conventions
- Use RuboCop for linting (run `bin/rubocop` before committing)
- Write idiomatic Ruby code with proper use of blocks, modules, and metaprogramming
- Use Turbo and Stimulus patterns for frontend interactions
- Follow the project's existing patterns for models, controllers, and views

## File Modification Rules

- Never modify `.env`, `.env.development`, or `.env.production` files
- Never commit `config/master.key` or any encrypted credentials files
- Always use `bin/rails credentials:edit` for sensitive configuration
- Follow Rails 8 conventions (Solid Queue, Solid Cache, Solid Cable)
- Use Active Storage for file uploads
- Database changes require migrations in `db/migrate/`

## Commit Discipline

- Write concise, descriptive commit messages following conventional commits
- Include issue references when applicable
- Never commit to `main` branch directly
- Run tests and linters before committing
- Ensure all CI checks pass before merging

## Security and Privacy

- Never log or expose user data, payment information, or secrets
- Use Rails parameter filtering for sensitive fields (`config/filter_parameter_logging`)
- Validate and sanitize all user inputs
- Use strong parameters for mass assignment
- Run `bin/brakeman` for security vulnerability scans
- Never add code that bypasses authentication or authorization

# Decision Boundaries

## Autonomous Decisions (No Approval Required)

- Adding unit tests for existing code
- Fixing typos and minor formatting issues
- Improving code comments and documentation
- Refactoring within the same module/class
- Adding dependencies that do not affect security or performance
- Running migrations in non-production environments
- Updating documentation

## Requires Explicit Human Approval

- Database schema changes (adding/removing columns, tables, indexes)
- Changes to payment processing logic
- Authentication/authorization modifications
- API endpoint changes
- Breaking changes to existing features
- Third-party service integrations
- Deployment to production
- Rolling back production changes

## Strictly Forbidden

- Committing secrets, keys, or credentials
- Bypassing authentication or authorization
- Removing security measures
- Disabling encryption or validation
- Modifying the encryption configuration
- Deleting production data
- Bypassing CI/CD checks

# Workflow Expectations

## Task Approach

1. **Analyze**: Understand the requirements, existing code structure, and impact
2. **Plan**: Create a clear plan with minimal changes, respecting existing patterns
3. **Act**: Implement changes following Rails conventions
4. **Verify**: Run tests, linters, and security scans

## Order of Operations

1. Search existing codebase for relevant patterns
2. Read related files to understand conventions
3. Create or modify code following project standards
4. Write or update tests
5. Run `bin/rubocop` and fix any issues
6. Run `bin/rails test` and `bin/rails test:system`
7. Run `bin/brakeman` to verify no new vulnerabilities
8. Verify the changes work as expected

## Error Handling

- Always handle exceptions gracefully
- Use proper error messages for user-facing errors
- Log errors appropriately for debugging
- Never expose stack traces to end users
- Test error paths and edge cases

# Testing & Validation

## Required Tests

- Unit tests for models (`test/models/*_test.rb`)
- Controller tests for business logic (`test/controllers/*_test.rb`)
- System tests for critical user flows (`test/system/*_test.rb`)
- Integration tests for API endpoints
- Tests must cover happy paths and error conditions

## Validation Before Completion

- All tests must pass (`bin/rails test test:system`)
- RuboCop must pass with no offenses (`bin/rubocop`)
- Brakeman must report no new vulnerabilities (`bin/brakeman`)
- Manual verification of changes in development environment
- Database migrations tested and reversible

## Test Coverage

- Maintain existing test coverage
- Add tests for new functionality
- Update tests when modifying existing behavior
- Ensure payment and authentication flows have comprehensive tests

# Communication Rules

## When to Communicate

- Unclear or ambiguous requirements
- Conflicting instructions or edge cases
- Discovered security vulnerabilities
- Potential breaking changes not explicitly requested
- Need for additional dependencies or infrastructure changes
- Unexpected performance impacts

## Uncertainty Handling

- Stop and ask when requirements are unclear
- Seek clarification on architectural decisions
- Propose multiple options when the best approach is unclear
- Clearly communicate risks and trade-offs

## Reporting Findings

- Report security issues immediately
- Document any workarounds or temporary fixes
- Highlight areas that need future improvement
- Note any assumptions made during implementation

# Failure Modes

## When Unsure

- Stop and ask for clarification
- Do not make assumptions about business logic
- Review existing patterns more thoroughly
- Propose options rather than choosing arbitrarily

## Conflicting Instructions

- Prioritize security and data integrity
- Ask for clarification on the conflict
- Document the conflict and resolution
- Do not proceed until the conflict is resolved

## Safe Shutdown Behavior

- Revert any incomplete or uncommitted changes
- Document work in progress and next steps
- Ensure no tests are left failing
- Clean up temporary files or branches
- Provide clear status on what was accomplished
