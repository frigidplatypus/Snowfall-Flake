---
description: Split all uncommitted changes into small, focused commits
---
Split the current working tree into small, focused commits.

Grouping hints from the user (may be empty): $ARGUMENTS

1. Inspect the pending work: `git status`, `git diff`, and skim untracked
   files. Check `git log --oneline -10` to match this repo's commit style.
2. Partition every uncommitted change — unstaged modifications and untracked
   files — into small logical groups, one coherent change each. Keep tightly
   coupled changes together (e.g. a module plus the host config that enables
   it), but never mix unrelated concerns in one commit. Prefer more, smaller
   commits over few large ones.
3. For each group, in dependency order: stage exactly those files with
   `git add <files>`, then commit. Short imperative subject line; body only
   when the "why" is not obvious from the subject.
4. If a file has partially staged hunks or the split is ambiguous, stop and
   ask instead of guessing. Never stage or commit files that look like
   plaintext secrets or build artifacts — report them instead.
5. Do not push. Finish with a one-line-per-commit summary and anything you
   deliberately skipped.
