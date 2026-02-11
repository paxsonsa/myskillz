# Paxdev Plugin Installation Guide

## Quick Install

Add the marketplace and install the plugin in Claude Code:

```
/plugin marketplace add https://github.com/paxsonsa/myskillz
/plugin install paxdev@myskillz --scope user
```

## Verification

After installation, verify the plugin is active:

```
/plugin
```

Then select "Manage Plugins" to see paxdev listed.

## Available Commands

Once installed, you can use these commands:

- `/research` - Research a codebase by spawning parallel sub-agents
- `/discovery` - Discover a repo and generate an LLM context guide
- `/create_plan` - Create detailed implementation plans
- `/implement_plan` - Implement an approved technical plan
- `/validate_plan` - Validate that a plan was implemented successfully
- `/validate_research` - Validate research documents against codebase reality
- `/commit` - Create git commits for changes made in session

Run `/help` to see all available commands including the paxdev commands.

## Updating the Plugin

To update after the repo has been updated:

```
/plugin uninstall paxdev
/plugin install paxdev@myskillz --scope user
```

Or simply restart Claude Code to reload plugin changes.

## Uninstalling

To remove the plugin:
```
/plugin uninstall paxdev
```

To remove the marketplace:
```
/plugin marketplace remove myskillz
```
