# markloop-plugin

The [Markloop](https://markloop.io) plugin for AI agents: publish the HTML
documents your agent writes, collect anchored comments from your team or
clients, and let the agent apply them and publish the next version at the same
link.

The plugin is one remote MCP server (`https://app.markloop.io/api/mcp`, OAuth
sign-in in the browser) plus one skill, `markloop-review`. It has no scripts,
hooks or local programs. What it sends and where is described in
[`plugin/README.md`](plugin/README.md).

## Install

### Claude Code

```text
/plugin marketplace add markloop-io/markloop-plugin
/plugin install markloop@markloop
```

The first Markloop request opens the browser to sign in. Run `/mcp` to see the
connection.

### Codex

```sh
codex plugin marketplace add markloop-io/markloop-plugin
codex plugin add markloop@markloop
```

The catalog is in `.agents/plugins/marketplace.json` and points at `./plugin`.

### Other tools

Connect the MCP server directly: https://markloop.io/docs/connect

## Layout

```
.claude-plugin/marketplace.json   Claude Code marketplace (one plugin: ./plugin)
.agents/plugins/marketplace.json  Codex local marketplace (./plugin)
plugin/
  .claude-plugin/plugin.json      Claude manifest
  .mcp.json                       Claude MCP config (type http, no secrets)
  plugin.json                     Agent Plugins manifest + OpenAI listing (extensions.com.openai)
  mcp.json                        Agent Plugins MCP config + OpenAI OAuth (DCR)
  skills/markloop-review/SKILL.md the skill
  assets/                         OpenAI logo and composer icon
  icon.png                        Claude icon
scripts/build-openai-zip.sh       builds the OpenAI upload ZIP (not part of the plugin)
```

## Build the OpenAI package

```sh
scripts/build-openai-zip.sh
```

It zips `plugin/` into `dist/markloop-openai-<version>.zip`, leaving out the
Claude-only files (`.claude-plugin/`, `.mcp.json`) and `.DS_Store`, checks that
the required files and every path in `plugin.json` exist, rejects `apps` and
hooks, and prints the ZIP listing. Upload the ZIP in the OpenAI Platform
(Plugins, "With MCP"). Test credentials and reviewer instructions go in the
dashboard, never in the package.

## Validate

```sh
claude plugin validate ./plugin
claude plugin validate .
```

## Links

- Documentation: https://markloop.io/docs
- Data and security: https://markloop.io/docs/data-security
- Privacy policy: https://markloop.io/privacy-policy
- Terms of service: https://markloop.io/terms-of-service
- Support: hi@markloop.io

Built by [Marcin Perłak](https://github.com/mperlak). License: MIT, © 2026 Marcin Perłak.
