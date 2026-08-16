---
trigger: manual
---


 I have finished working on the current branch. Please help me prepare the Pull Request, the Merge Message, and the Release Notes based on the changes.

 **Instructions for the AI:**
 1. **Context Gathering:** Read our recent chat history, check all the commits made in this branch, and use `git diff` (or other git commands) to fully understand everything that actually changed. I want the details to be as accurate and comprehensive as possible.
 
 2. **For the PR:**
    - **Title:** Give me a concise PR title following the conventional commit format (e.g., `fix(scope): description`). **Do not** include the branch name.
    - **Description:** Write a detailed PR description using the exact format from `.github/pull_request_template.md` (Summary, Type of change, How I tested, Screenshots, Checklist). Check the appropriate boxes by replacing `[ ]` with `[x]`.
    - **Important:** Do **NOT** fill in the "Closes #" line. Just leave it as `Closes #` or omit it, as I will handle the issue linking myself.
 
 3. **For the Merge Message:**
    - **Title:** Provide a merge commit title in this exact format: `"Merge pull request #[PR_NUMBER] from [username]/[branch_name]: [PR_TITLE]"` (Use placeholders for the PR number and branch name if you don't know them).
    - **Extended Description:** Provide a bulleted list summarizing the key changes for the extended merge description (e.g., `- Redesigned top-left feather icon SVG...`).

 4. **For the Release Logs:**
    - Do not include the main title (e.g., "Feather MD v1.5.1") as I already have it.
    - **First Line:** Start by clearly stating the nature of the update (e.g., whether it is a major, minor, big, severe, or security update).
    - **User-Friendly Summary:** Provide a point-wise breakdown of the changes explained simply for non-technical users.
    - **Technical Details:** Following the simple summary, provide a highly detailed, technical description of everything that was done in this release.
