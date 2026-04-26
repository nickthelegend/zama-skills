# Zama Skills Maintenance Metadata

This file outlines the maintenance schedule and quality standards for the `zama-skills` repository.

## 1. Versioning Policy
- **Minor Updates (x.y.z)**: Documentation fixes, dependency updates, new reference files.
- **Major Updates (X.0.0)**: New skill additions, architectural shifts in FHEVM (e.g., transition to v2.0 Coprocessor), or structural changes to the library.

## 2. Quality Control Checklist
- Every skill must have a `references/` folder with at least 5 working files.
- `SKILL.md` files must follow the Elite template (YAML frontmatter + Mermaid diagrams + AI prompts).
- All code in `references/` must be 100% self-contained.

## 3. Community Moderation
- Issues should be labeled: `bug`, `new-skill-request`, `documentation`.
- Pull Requests require validation against the latest `@fhevm/solidity` version.

## 4. Automation
The `.github/workflows/ci.yml` file handles automated linting. In v7.0, we plan to add automated Hardhat testing for every skill's `references/` folder.
