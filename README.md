# Claude Gateway Plugin

A Claude Code plugin that integrates with [Claude Gateway](https://github.com/jdscript/claude-gateway).

## Installation

In Claude Code, run:

```
/plugin marketplace add JDScript/claude-code-marketplace
/plugin install claude-gateway
```

## Configuration

Set these environment variables in your shell profile (`~/.zshrc` or `~/.bashrc`):

```sh
export ANTHROPIC_AUTH_TOKEN=<your-api-key>
export ANTHROPIC_BASE_URL=<your-gateway-url>/api
```

## How it works

- On each Claude Code session start, the plugin syncs your hook rules from the gateway platform
- Hook rules are configured in the gateway web UI under **Hooks**
- Only matched events are sent to the server, keeping latency low
- The plugin auto-updates itself via `git pull` on each session start

## Uninstall

In Claude Code, run:

```
/plugin uninstall claude-gateway
```
