# Purpose

This is a Ruby on Rails 8 e-commerce application that includes:
- Product and digital product catalog management
- Shopping cart and order processing
- Donation collection with payment evidence
- Payment gateway integration (Midtrans)
- Admin interface for site management
- Email notifications

AI agents are authorized to operate here to accelerate feature development, bug fixes, code quality improvements, and operational tasks while maintaining production-grade quality standards.

# Todo.txt Task Tracking

## Source of Truth

**Todo.txt is the task tracking system for this repository.**

Tasks are stored in:
- `todo.todotxt` - Active tasks to work on
- `done.todotxt` - Completed tasks

Before starting any work, agents MUST:
1. Read `todo.todotxt` to see available tasks
2. Find or create a task for the requested work

## Task Format

Todo.txt format:
```
(A) Task description +project @context due:yyyy-mm-dd
```

- **Priority**: (A) highest, (B), (C), (D), (E) lowest
- **Project**: +projectname (e.g., +auth, +payments)
- **Context**: @context (e.g., @bug, @feature, @urgent)
- **Creation Date**: yyyy-mm-dd (optional, added automatically)

## Task Responsibilities

### Starting Work

1. **Find existing task**: Read `todo.todotxt` for matching task
2. **Create task if needed**: Add new task to `todo.todotxt` if none exists
3. **Mark as in-progress**: Optionally add @in-progress context

### During Work

1. **Update task status**: Move task within `todo.todotxt` to reflect progress
2. **Record decisions**: Add notes as comments in `todo.todotxt` (lines starting with #)
3. **Create new tasks**: Add new tasks to `todo.todotxt` for discovered work

### Finishing Work

1. **Verify completion**: Ensure task requirements are met
2. **Move to done**: Move task from `todo.todotxt` to `done.todotxt` with completion date
3. **Commit changes**: Commit both todo.todotxt and done.todotxt

## Task Discipline

Agents MUST:
- Read `todo.todotxt` before starting work
- Create tasks for all work
- Move completed tasks to `done.todotxt`

Agents MUST NOT:
- Work without tracking it in todo.todotxt
- Delete tasks from done.todotxt (they form history)

When requirements are unclear:
1. Add task to `todo.todotxt` with @question context
2. Wait for clarification before proceeding
3. NEVER guess or make assumptions

## Example Task Workflow

### Task Creation

Add to `todo.todotxt`:
```
(A) Add product search with filters +search @feature due:2026-02-15
```

### During Work

Update task in `todo.todotxt`:
```
(A) Add product search with filters +search @feature @in-progress
# Chose Postgres full-text search over external service
```

Create discovered task:
```
(B) Add product_name index for search performance +database @optimization
```

### Task Completion

Move to `done.todotxt`:
```
x 2026-02-11 2026-02-01 Add product search with filters +search @feature
# Search and filters implemented with tests passing
```

# Agent Roles

## Coding Agent

**Responsibilities:**
- Implement new features and functionality
- Fix bugs and resolve issues
- Refactor existing code for maintainability
- Write and maintain tests
- Follow Rails conventions and project patterns
- Track all work in todo.todotxt

**MUST NOT:**
- Modify database schema without explicit approval
- Commit changes to `main` branch
- Deploy to production environments
- Change encryption keys or secrets
- Modify payment gateway configurations without approval
- Work without tracking in todo.todotxt

## Review Agent

**Responsibilities:**
- Review pull requests for code quality and correctness
- Verify adherence to coding standards
- Check for security vulnerabilities
- Validate test coverage
- Ensure documentation accuracy
- Track review work in todo.todotxt

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
- Track operational tasks in todo.todotxt

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
- NEVER remove existing routes from `config/routes.rb` unless explicitly requested and approved

## Commit Discipline

- Write concise, descriptive commit messages following conventional commits
- Include task reference in commit messages: `git commit -m "Add search feature (+search)"`
- Never commit to `main` branch directly
- Run tests and linters before committing
- Ensure all CI checks pass before merging
- Commit todo.todotxt/done.todotxt changes with relevant commits

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
- Working without tracking in todo.todotxt

# Workflow Expectations

## Task Approach

1. **Read tasks**: Read `todo.todotxt` for existing tasks
2. **Create task if needed**: Add to `todo.todotxt` if none exists
3. **Analyze**: Read task requirements, understand existing code structure and impact
4. **Plan**: Create implementation plan, add notes as comments to task
5. **Act**: Implement changes following Rails conventions
6. **Verify**: Run tests, linters, and security scans
7. **Update tasks**: Move task to `done.todotxt` when complete

## Plan Approval Workflow

**CRITICAL: When user approves a plan, IMMEDIATELY create tasks based on that plan.**

1. **Present plan**: Show implementation breakdown before starting work
2. **Await approval**: Stop and wait for user to approve the plan
3. **Create tasks on approval**: Once user says "approved" or similar, immediately create tasks:
   - Add tasks to `todo.todotxt` for each major task in the plan
   - Set appropriate priority ((A), (B), (C), (D), (E))
   - Add project tags (+auth, +payments, etc.)
   - Add context tags (@feature, @bug, @optimization, etc.)
   - Include acceptance criteria as comments
4. **Confirm creation**: List all created tasks with their priorities
5. **Begin execution**: Start work on highest priority task

**Example:**

Add to `todo.todotxt`:
```
(A) Add user authentication +auth @feature due:2026-02-20
# Implement login/signup with Devise

(B) Create users table migration +auth +database @task
# Add users table with email/password

(B) Set up Devise configuration +auth @task

(C) Build login form +auth @frontend

(C) Add authentication tests +auth +testing @task
```

## Order of Operations

1. Read `todo.todotxt` for existing tasks
2. Read task requirements and acceptance criteria
3. Search existing codebase for relevant patterns
4. Read related files to understand conventions
5. Create or modify code following project standards
6. Write or update tests
7. Run `bin/rubocop` and fix any issues
8. Run `bin/rails test`
9. Run `bin/brakeman` to verify no new vulnerabilities
10. Update task in `todo.todotxt` with progress
11. Verify changes work as expected
12. Move task from `todo.todotxt` to `done.todotxt`
13. Commit both todo.todotxt and done.todotxt

## Error Handling

- Always handle exceptions gracefully
- Use proper error messages for user-facing errors
- Log errors appropriately for debugging
- Never expose stack traces to end users
- Test error paths and edge cases
- Create new tasks in `todo.todotxt` for discovered bugs or issues

# Testing & Validation

## Required Tests

- Unit tests for models (`test/models/*_test.rb`)
- Controller tests for business logic (`test/controllers/*_test.rb`)
- System tests for critical user flows (`test/system/*_test.rb`)
- Integration tests for API endpoints
- Tests must cover happy paths and error conditions
- Test coverage requirements should be documented as task comments

## Validation Before Completion

- All tests must pass (`bin/rails test test:system`)
- RuboCop must pass with no offenses (`bin/rubocop`)
- Brakeman must report no new vulnerabilities (`bin/brakeman`)
- Manual verification of changes in development environment
- Database migrations tested and reversible
- All acceptance criteria for the task are met

## Test Coverage

- Maintain existing test coverage
- Add tests for new functionality
- Update tests when modifying existing behavior
- Ensure payment and authentication flows have comprehensive tests
- Document any test coverage gaps as task comments

# Communication Rules

## When to Communicate

- Unclear or ambiguous task requirements
- Conflicting instructions or edge cases
- Discovered security vulnerabilities
- Potential breaking changes not explicitly requested
- Need for additional dependencies or infrastructure changes
- Unexpected performance impacts

## Uncertainty Handling

- Stop and add note to task with specific questions
- Seek clarification on architectural decisions
- Propose multiple options when the best approach is unclear
- Clearly communicate risks and trade-offs in task comments
- NEVER guess - add question to task and wait for response

## Reporting Findings

- Report security issues immediately
- Document any workarounds or temporary fixes in task comments
- Highlight areas that need future improvement
- Note any assumptions made during implementation
- Create new tasks in `todo.todotxt` for follow-up work

# Failure Modes

## When Unsure

- Stop and add note to task with questions
- Do not make assumptions about business logic
- Review existing patterns more thoroughly
- Propose options rather than choosing arbitrarily

## Conflicting Instructions

- Prioritize security and data integrity
- Update task with conflict details
- Ask for clarification on the conflict
- Document the conflict and resolution in task comments
- Do not proceed until the conflict is resolved

## Safe Shutdown Behavior

- Revert any incomplete or uncommitted changes
- Update in-progress tasks in `todo.todotxt` with current state
- Ensure no tests are left failing
- Clean up temporary files or branches
- Commit todo.todotxt and done.todotxt
- Provide clear status on what was accomplished

# Landing the Plane (Session Completion)

When ending a work session, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **Update tasks** - Move completed tasks to `done.todotxt`, update in-progress tasks in `todo.todotxt`
2. **Create tasks for remaining work** - Add tasks to `todo.todotxt` for anything that needs follow-up
3. **Run quality gates** (if code changed) - Tests, linters, builds
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   git add todo.todotxt done.todotxt <other files>
   git commit -m "..."
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed, tasks updated
7. **Hand off** - Provide context for next session with task IDs

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
- Always include task/project references in commit messages
- Ensure todo.todotxt and done.todotxt accurately reflect work state

---

## Todo.txt Workflow Integration

This project uses [todo.txt](https://github.com/todotxt/todo.txt-cli) for task tracking. Tasks are stored in `todo.todotxt` (active) and `done.todotxt` (completed) and tracked in git.

### Task Management

```bash
# Read tasks
cat todo.todotxt     # View all active tasks
cat done.todotxt     # View completed tasks

# Edit tasks (use any text editor)
vim todo.todotxt     # Add/update tasks
vim done.todotxt     # View completed tasks

# Move task from todo to done
# 1. Copy task line from todo.todotxt
# 2. Add 'x <completion-date> <creation-date>' prefix
# 3. Paste to done.todotxt
# 4. Remove from todo.todotxt
```

### Workflow Pattern

1. **Start**: Read `todo.todotxt` to find actionable work
2. **Claim**: Add @in-progress context to task
3. **Work**: Implement the task, update progress as comments
4. **Complete**: Move task from `todo.todotxt` to `done.todotxt`
5. **Commit**: Commit both files at session end

### Key Concepts

- **Priority**: (A) highest → (E) lowest
- **Project**: +projectname (categorize tasks)
- **Context**: @context (filter by type: @feature, @bug, @urgent, @in-progress)
- **Dates**: Optional, format yyyy-mm-dd

### Session Protocol

**Before ending any session, run this checklist:**

```bash
git status              # Check what changed
git add todo.todotxt done.todotxt <files>  # Stage all changes
git commit -m "..."     # Commit
git push                # Push to remote
```

### Best Practices

- Read `todo.todotxt` at session start to find available work
- Update tasks as you work (add @in-progress, add comments)
- Create new tasks in `todo.todotxt` when you discover work
- Use descriptive task descriptions and set appropriate priority
- Always commit `todo.todotxt` and `done.todotxt` before ending session
