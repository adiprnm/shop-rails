# Purpose

This is a Ruby on Rails 8 e-commerce application that includes:
- Product and digital product catalog management
- Shopping cart and order processing
- Donation collection with payment evidence
- Payment gateway integration (Midtrans)
- Admin interface for site management
- Email notifications

AI agents are authorized to operate here to accelerate feature development, bug fixes, code quality improvements, and operational tasks while maintaining production-grade quality standards.

# Beads Issue Tracking

## Source of Truth

**Beads is the ONLY authoritative issue tracker for this repository.**

All planning, task assignment, and work coordination must happen through Beads. The following are NOT authoritative:
- GitHub Issues
- TODO comments in code
- Chat memory or conversation history
- External ticketing systems

Before starting any work, agents MUST:
1. Read existing beads using `bd list` or `bd ready`
2. Locate the relevant bead for the requested work
3. If no bead exists, create one BEFORE coding

## Bead Responsibilities

### Starting Work

1. **Locate relevant bead**: Use `bd list` or search for existing beads matching the work description
2. **Create bead if needed**: If no matching bead exists, create one with `bd create "<title>" -p <priority> -t <type>`
3. **Set status to active**: Use `bd update <id> --status in_progress` before beginning implementation
4. **Add blockers if needed**: Use `bd dep add <child> <parent>` to link dependencies

### During Work

1. **Update bead status**: Change status as work progresses (`in_progress`, `blocked`, `completed`)
2. **Record decisions**: Add notes to the bead documenting architectural choices, trade-offs, or alternatives considered
3. **Link discovered work**: When new issues emerge, create new beads with `bd create "<title>" --deps discovered-from:<parent-id>`
4. **Update dependencies**: If dependencies change during implementation, update with `bd dep add` or `bd dep remove`

### Finishing Work

1. **Verify completion**: Ensure all acceptance criteria in the bead are met
2. **Mark complete**: Use `bd close <id> --reason "<explanation>"` when work is done
3. **Handle blockers**: If work cannot be completed, mark as blocked with rationale: `bd update <id> --status blocked` and add note explaining why
4. **Sync changes**: Always run `bd sync` after making bead changes to commit to git

## Bead Discipline

Agents MUST NOT:
- Work without a corresponding bead
- Create hidden tasks or work items
- Assume intent not explicitly written in a bead
- Rely on chat instructions that aren't reflected in a bead

When requirements are unclear:
1. Update the bead with specific questions
2. Use `bd update <id> --notes "<question>"` to add clarification requests
3. Wait for bead to be updated before proceeding
4. NEVER guess or make assumptions about ambiguous requirements

## Bead Lifecycle

Beads follow this status progression:

- **New**: Created but not yet started. Default status after `bd create`
- **Active** (`in_progress`): Agent is currently working on this bead
- **Blocked** (`blocked`): Work cannot proceed due to dependencies, missing information, or external factors
- **Completed** (`closed`): Work is finished and all acceptance criteria are met

**Status transitions:**
- New → Active: Agent claims the work
- Active → Blocked: Agent encounters an obstacle and documents why
- Blocked → Active: Obstacle is resolved
- Active → Completed: Work is finished
- Any → New: Bead is reopened (rare, usually for follow-up work)

## Example Bead Workflow

### Initial Bead Creation

```bash
# Create a new bead for a feature request
bd create "Add product search with filters" -p 1 -t feature -d "Implement keyword search with price range and category filters"
# Returns: bd-a3f8e9

# Add dependencies if needed
bd dep add bd-a3f8e9 bd-x1y2  # depends on existing database schema bead
```

### Agent Working on Bead

```bash
# Claim the work
bd update bd-a3f8e9 --status in_progress

# During implementation, discover a missing index
bd create "Add product_name index for search performance" -p 1 --deps discovered-from:bd-a3f8e9
# Returns: bd-b7c9d2

# Record decision about search implementation
bd update bd-a3f8e9 --notes "Chose Postgres full-text search over external service to reduce dependencies and costs"

# Hit blocker - need clarification on filter behavior
bd update bd-a3f8e9 --status blocked
bd update bd-a3f8e9 --notes "BLOCKED: Need clarification on whether price filters should include or exclude boundary values"
```

### After Clarification

```bash
# Bead updated by human with clarification
bd update bd-a3f8e9 --status in_progress

# Complete implementation
bd close bd-a3f8e9 --reason "Search and filters implemented with tests passing"

# Sync to git
bd sync
```

# Agent Roles

## Coding Agent

**Responsibilities:**
- Implement new features and functionality
- Fix bugs and resolve issues
- Refactor existing code for maintainability
- Write and maintain tests
- Follow Rails conventions and project patterns
- Create and update beads for all work

**MUST NOT:**
- Modify database schema without explicit approval
- Commit changes to `main` branch
- Deploy to production environments
- Change encryption keys or secrets
- Modify payment gateway configurations without approval
- Work without an active bead

## Review Agent

**Responsibilities:**
- Review pull requests for code quality and correctness
- Verify adherence to coding standards
- Check for security vulnerabilities
- Validate test coverage
- Ensure documentation accuracy
- Verify beads are properly updated after work

**MUST NOT:**
- Auto-approve changes that modify critical paths (payments, authentication)
- Bypass security reviews
- Merge without verifying all CI checks pass
- Close review beads without confirming fixes are implemented

## Ops Agent

**Responsibilities:**
- Run database migrations
- Manage environment variables and secrets
- Execute deployment procedures
- Monitor application health
- Apply dependency updates after verification
- Update beads with operational tasks and issues

**MUST NOT:**
- Modify application code
- Rollback production without approval
- Change infrastructure outside defined procedures
- Expose or log secrets
- Make infrastructure changes without a bead

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
- NEVER remove existing routes from `config/routes.rb` unless explicitly requested and approved

## Commit Discipline

- Write concise, descriptive commit messages following conventional commits
- Include bead references in commit messages: `git commit -m "Add search feature (bd-a3f8e9)"`
- Never commit to `main` branch directly
- Run tests and linters before committing
- Ensure all CI checks pass before merging
- Always run `bd sync` after bead changes before committing

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
- Working without a bead

# Workflow Expectations

## Task Approach

1. **Locate bead**: Search for existing bead matching the work
2. **Create bead if needed**: If none exists, create one before starting
3. **Analyze**: Read bead requirements, understand existing code structure and impact
4. **Plan**: Create implementation plan, update bead with approach
5. **Act**: Implement changes following Rails conventions
6. **Verify**: Run tests, linters, and security scans
7. **Update bead**: Mark progress, record decisions, close when complete

## Order of Operations

1. Locate or create bead for the work
2. Read bead requirements and acceptance criteria
3. Set bead status to `in_progress`
4. Search existing codebase for relevant patterns
5. Read related files to understand conventions
6. Create or modify code following project standards
7. Write or update tests
8. Run `bin/rubocop` and fix any issues
9. Run `bin/rails test` and `bin/rails test:system`
10. Run `bin/brakeman` to verify no new vulnerabilities
11. Update bead with progress and decisions
12. Verify changes work as expected
13. Mark bead as `completed` or `blocked` with rationale
14. Run `bd sync` to commit bead changes
15. Commit code changes with bead reference

## Error Handling

- Always handle exceptions gracefully
- Use proper error messages for user-facing errors
- Log errors appropriately for debugging
- Never expose stack traces to end users
- Test error paths and edge cases
- Update beads with discovered bugs or issues

# Testing & Validation

## Required Tests

- Unit tests for models (`test/models/*_test.rb`)
- Controller tests for business logic (`test/controllers/*_test.rb`)
- System tests for critical user flows (`test/system/*_test.rb`)
- Integration tests for API endpoints
- Tests must cover happy paths and error conditions
- Test coverage requirements should be documented in beads

## Validation Before Completion

- All tests must pass (`bin/rails test test:system`)
- RuboCop must pass with no offenses (`bin/rubocop`)
- Brakeman must report no new vulnerabilities (`bin/brakeman`)
- Manual verification of changes in development environment
- Database migrations tested and reversible
- All acceptance criteria in the bead are met

## Test Coverage

- Maintain existing test coverage
- Add tests for new functionality
- Update tests when modifying existing behavior
- Ensure payment and authentication flows have comprehensive tests
- Document any test coverage gaps in beads

# Communication Rules

## When to Communicate

- Unclear or ambiguous requirements in beads
- Conflicting instructions or edge cases
- Discovered security vulnerabilities
- Potential breaking changes not explicitly requested
- Need for additional dependencies or infrastructure changes
- Unexpected performance impacts

## Uncertainty Handling

- Stop and update the bead with specific questions
- Seek clarification on architectural decisions
- Propose multiple options when the best approach is unclear
- Clearly communicate risks and trade-offs in bead notes
- NEVER guess - update bead and wait for response

## Reporting Findings

- Report security issues immediately
- Document any workarounds or temporary fixes in beads
- Highlight areas that need future improvement
- Note any assumptions made during implementation
- Create beads for follow-up work

# Failure Modes

## When Unsure

- Stop and update the bead with questions
- Do not make assumptions about business logic
- Review existing patterns more thoroughly
- Propose options rather than choosing arbitrarily

## Conflicting Instructions

- Prioritize security and data integrity
- Update bead with conflict details
- Ask for clarification on the conflict
- Document the conflict and resolution in the bead
- Do not proceed until the conflict is resolved

## Safe Shutdown Behavior

- Revert any incomplete or uncommitted changes
- Update in-progress beads with current state
- Ensure no tests are left failing
- Clean up temporary files or branches
- Run `bd sync` to save bead state
- Provide clear status on what was accomplished

# Landing the Plane (Session Completion)

When ending a work session, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **Update bead status** - Set beads to appropriate status (`completed`, `in_progress`, `blocked`)
2. **Create beads for remaining work** - File beads for anything that needs follow-up
3. **Run quality gates** (if code changed) - Tests, linters, builds
4. **Run `bd sync`** - Commit all bead changes
5. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
6. **Clean up** - Clear stashes, prune remote branches
7. **Verify** - All changes committed AND pushed, beads synced
8. **Hand off** - Provide context for next session with bead IDs

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
- Always include bead references in commit messages
- Ensure beads accurately reflect work state

<!-- bv-agent-instructions-v1 -->

---

## Beads Workflow Integration

This project uses [beads_viewer](https://github.com/Dicklesworthstone/beads_viewer) for issue tracking. Issues are stored in `.beads/` and tracked in git.

### Essential Commands

```bash
# View issues (launches TUI - avoid in automated sessions)
bv

# CLI commands for agents (use these instead)
bd ready              # Show issues ready to work (no blockers)
bd list --status=open # All open issues
bd show <id>          # Full issue details with dependencies
bd create --title="..." --type=task --priority=2
bd update <id> --status=in_progress
bd close <id> --reason="Completed"
bd close <id1> <id2>  # Close multiple issues at once
bd sync               # Commit and push changes
```

### Workflow Pattern

1. **Start**: Run `bd ready` to find actionable work
2. **Claim**: Use `bd update <id> --status=in_progress`
3. **Work**: Implement the task
4. **Complete**: Use `bd close <id>`
5. **Sync**: Always run `bd sync` at session end

### Key Concepts

- **Dependencies**: Issues can block other issues. `bd ready` shows only unblocked work.
- **Priority**: P0=critical, P1=high, P2=medium, P3=low, P4=backlog (use numbers, not words)
- **Types**: task, bug, feature, epic, question, docs
- **Blocking**: `bd dep add <issue> <depends-on>` to add dependencies

### Session Protocol

**Before ending any session, run this checklist:**

```bash
git status              # Check what changed
git add <files>         # Stage code changes
bd sync                 # Commit beads changes
git commit -m "..."     # Commit code
bd sync                 # Commit any new beads changes
git push                # Push to remote
```

### Best Practices

- Check `bd ready` at session start to find available work
- Update status as you work (in_progress → closed)
- Create new issues with `bd create` when you discover tasks
- Use descriptive titles and set appropriate priority/type
- Always `bd sync` before ending session

<!-- end-bv-agent-instructions -->
