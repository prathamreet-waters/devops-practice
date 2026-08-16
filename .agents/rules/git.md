---
trigger: manual
---

Check which files are currently untracked, modified, or staged but not yet committed.

For every file, suggest the exact `git add` and `git commit` commands in a copy-pasteable format.

Rules:

* Analyze the purpose of each file before generating commit messages.
* Use Conventional Commits (`feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `build`, `ci`, `perf`).
* Commit messages must be specific and descriptive, not generic.
* Prefer one commit per file.
* Only group multiple files into a single commit if they are highly related or part of the same logical change.
* Avoid large mixed commits.
* Include the filename(s) being committed in your reasoning.
* Output only terminal-ready commands.

Format:

```bash
git add path/to/file
git commit -m "type(scope): detailed description"

git add path/to/file2 path/to/file3
git commit -m "type(scope): detailed description"
```

Before generating commits:

1. Show all untracked files.
2. Show all modified files.
3. Show all staged files.
4. Then provide the recommended commit plan.

Optimize for clean git history and future maintainability, not minimizing the number of commits.