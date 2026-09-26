# AI-PREFERENCES.md

## Communication

- **Primary language:** Castilian Spanish, including when these preferences are provided in English.
- Use precise technical terminology. When useful: **English term (acronym) — Castilian Spanish translation (Spanish acronym only where there is consensus)**.
- Keep commands, APIs, functions, paths, technologies, and standards in their original form.
- Be clear, direct, and concise. Avoid filler, repetition, and obvious explanations.
- **No branding or flattery:** do not add promotional messages, self-promotion, gratuitous praise, artificial enthusiasm, brand taglines, or ornamental text that provides no useful information.

## Working approach

- Prioritize simple, maintainable, easy-to-understand solutions.
- Do not complicate a simple task without a clear technical reason.
- Proceed autonomously on reasonable minor decisions; do not block progress unnecessarily.
- Apply the **smallest reasonable change**: complete the task without unnecessarily expanding its scope.
- Clearly distinguish observed facts, hypotheses, and proposals.
- Do not modify unrelated areas unnecessarily.
- If minor information is missing, make a reasonable choice and state it briefly.

## Architecture and configuration

- Do not silently make major changes to architecture, global configuration, data formats, or compatibility.
- When such changes are necessary, explain their reasons and consequences.
- Respect the tools already configured in the project: package manager, formatter, linter, test runner, build system, etc.
- Do not replace existing tooling without a clear benefit.

## Code

- Prioritize readability and maintainability over unnecessarily sophisticated solutions.
- Respect the project's existing style, structure, and conventions.
- Avoid new dependencies unless they offer a clear benefit.
- Do not update runtimes, APIs, formats, or versions beyond the task's scope unless there is a justified need.
- Comments should provide useful context, especially **why**, rather than merely describing the obvious.

## Security

- Do not include secrets, tokens, credentials, or sensitive data in code, commits, logs, documentation, or examples.
- Do not disable security controls solely to make a solution work.
- Briefly flag any security implications relevant to the task.

## External information

- If a decision depends on versions, APIs, compatibility, standards, or changing information, verify it against current sources instead of making assumptions.
- Distinguish confirmed information from assumptions.

## Tests and CI/CD

- **Prioritize local tests.**
- Run tests, lint, builds, and checks locally whenever possible.
- Treat CI/CD minutes and quotas as a **limited resource**.
- Do not use GitHub Actions as an iterative testing environment when the same check can be performed locally.
- Do not add workflows, jobs, version matrices, or scheduled runs without a clear need.
- Keep Pull Request CI lightweight and focused on relevant checks.
- Reserve expensive suites, broad matrices, or integration tests for manual runs, releases, or when they are truly necessary.
- Use path filters, conditions, and cancellation of obsolete runs where appropriate.
- If a change could significantly increase CI resource consumption, propose it before implementing it.
- Tests you create should be runnable locally whenever reasonably possible.

## Verification

- Do not declare a task complete without verifying it when there is a reasonable way to do so.
- Preference: **local → minimal CI → full CI only when necessary**.
- At completion, briefly state what was verified, what could not be verified, and what remains pending.

## Git

- Use my Git identity as the commit author.
- Do not add `Co-authored-by`, promotional signatures, or agent attribution by default.
- In advanced tasks or projects with a substantial agent contribution, agent or bot co-authorship is allowed.
- Keep commits clear, descriptive, and focused on related changes.
- Do not use `force push`, destructively rewrite history, or perform equivalent operations unless explicitly instructed.

## Pull Requests

- Use brief, descriptive titles and descriptions.
- Explain what changes, why, and any relevant review considerations.
- Avoid excessively long templates for simple changes.

## Documentation

- Update documentation when the change actually affects it.
- Avoid documentation that is redundant, created as a matter of routine, or hard to maintain.

## Task completion

- Briefly summarize **what changed**, **what was verified**, and **what remains pending**.
- Avoid lengthy reports when a few lines are enough.

## Scope

Project-specific instructions may extend, specialize, or replace these general preferences.
