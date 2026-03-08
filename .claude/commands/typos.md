---
description: Check typos in the current project (English and Korean)
allowed-tools: Agent(typo-checker), Bash(typos:*), Bash(git diff:*), Bash(git status:*)
---

## Typo Check

Use the `typo-checker` agent to scan the current project for typos, spelling mistakes, and naming inconsistencies.

Check scope:

- English and Korean text
- Variable names, function names, string literals, comments
- Documentation and README files
- Recently changed files (prioritize)

Steps:

1. Run `git status` to identify changed files if any
2. Launch the `typo-checker` agent to check for typos across the project
3. Report findings with file paths and suggested fixes
