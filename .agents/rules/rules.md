---
trigger: always_on
---

# Project Rules

## General

* Do not use emojis anywhere in the project unless explicitly requested.
* Maintain consistent UI/UX patterns across all pages, components, and interactions.
* Follow the existing design system, styling conventions, and component architecture.
* Prioritize clean, readable, and modular code.
* Avoid unnecessary complexity or over-engineering.
* Reuse existing components, utilities, and patterns whenever possible.

## Code Quality

* Keep files focused on a single responsibility.
* Prefer composition over duplication.
* Maintain consistent naming conventions.
* Remove dead code, unused imports, and unnecessary comments.
* Ensure new code integrates cleanly with the existing codebase.

## Safety Restrictions

* Do not run build, development, lint, test, or deployment commands unless explicitly requested by the user.
* Do not open or test the application in a browser unless explicitly requested by the user.
* Do not execute scripts that modify project state unless explicitly requested by the user.

## Git Restrictions

* Do not create commits unless explicitly requested by the user.
* Do not push, pull, merge, rebase, or modify git history unless explicitly requested by the user.
* Do not create tags or releases unless explicitly requested by the user.

## Versioning

* Do not modify version numbers in package files, manifests, lockfiles, release files, or changelogs unless explicitly requested by the user.
* Do not generate releases, release notes, or version bumps automatically.

## Before Making Changes

* Analyze the existing implementation first.
* Preserve project conventions and architecture.
* Minimize unnecessary file modifications.
* Prefer the smallest change that correctly solves the problem.
