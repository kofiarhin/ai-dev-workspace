# Safety and Verification

## Stop conditions

Stop or skip the affected operation when:

- the PRD is missing or unreadable;
- multiple PRDs remain plausible and none was explicitly selected;
- a write would leave the resolved workspace;
- an existing target contains materially conflicting instructions;
- permissions prevent a required write.

## Safe defaults

- Keep existing application code unchanged.
- Never follow a symlink for a write outside the workspace.
- Preserve existing content and uncommitted changes.
- Redact secret values while retaining non-sensitive variable names when useful.
- Use a meaningful `README.md` to represent a future-content directory; do not add `.gitkeep`.
- Use the user's requested language. Otherwise follow the PRD's primary language.

## Verification

After setup:

1. Confirm every reported file exists.
2. Search generated files for unresolved template markers such as `{{...}}`, `[TODO]`, and example product names.
3. Search generated files for accidentally copied secret values when safe identifiers are known.
4. Confirm no runtime-code, dependency, lockfile, Git-state, deployment, or external-service changes occurred.
5. Inspect the diff when Git is available and classify each target as created, updated, reused, skipped, or blocked.

Do not run application tests or builds for a documentation-only setup unless project instructions explicitly require them. Report those checks as not run rather than implying success.
