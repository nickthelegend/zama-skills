# Zama AI Agents Configuration

This repository is optimized for consumption by AI agents (Claude, Cursor, GPT-4).

## Agent Usage Patterns

### For Cursor / VS Code Copilot
1.  **Index the Repo**: Ensure the `skills/` directory is indexed.
2.  **Referencing Skills**: Ask the agent: "Use the `zama-confidential-erc20-token` skill to implement a private payout system."

### For Claude / ChatGPT
Paste the content of a specific `SKILL.md` to provide the agent with protocol-specific knowledge.

## Logic Flow for Agents
1.  **Understand Types**: Always use `euint` for sensitive data.
2.  **Handle Inputs**: Use `externalEuint` + `proof` for inputs from users.
3.  **Manage Permissions**: Explicitly call `FHE.allow` or `FHE.allowThis` for every ciphertext handle.
4.  **Async Decryption**: Handle the 2-step process (Request -> Callback) for public reveals.

## Troubleshooting for Agents
If the agent generates code that uses standard `if` statements on encrypted values, point them to the `zama-security-auditing-best-practices` skill.
