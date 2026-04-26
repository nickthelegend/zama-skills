# Contributing to Zama Skills

We welcome contributions to the Zama Skills library! Whether you are fixing a bug, improving documentation, or adding a new FHEVM skill, your help is appreciated.

## How to Add a New Skill
1.  **Create a Folder**: `skills/zama-<your-skill-name>`
2.  **Add SKILL.md**: Follow the v4.0 template (YAML frontmatter + rich documentation).
3.  **Include References**: Add real code, tests, and configs to the `references/` subfolder.
4.  **Update README**: Add your skill to the directory table.

## Coding Standards
- Use `BSD-3-Clause-Clear` for all new contracts.
- Ensure all skills are 100% self-contained.
- Optimize for AI agent consumption (clear headers, copy-paste snippets).

## Pull Requests
- Provide a clear description of the new skill or fix.
- Ensure all reference code compiles with `@fhevm/solidity`.
