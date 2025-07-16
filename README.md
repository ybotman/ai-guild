# Guild CLI

AI Guild is a comprehensive development methodology and workflow system designed to enable AI agents (like Claude) to work effectively with human developers on software projects.

## Installation

```bash
npm install -g @hdtsllc/guild
```

## Quick Start

After installation, navigate to your project directory and run:

```bash
guild setup
```

This will install the Guild documentation and configuration files into your project:

- `.guild/` - Guild documentation and workflows
- `CLAUDE.md` - Instructions for AI assistants
- `.guild-config` - Guild configuration file

## Commands

### `guild setup`

Copies the Guild documentation and configuration files into your current project directory.

Options:
- `--dry-run` - Shows what would be copied without actually copying any files
- `--help` - Display help information

Example with dry-run:
```bash
guild setup --dry-run
```

## What is Guild?

Guild provides:

1. **Structured Development Workflows** - Well-defined processes for AI-human collaboration
2. **Role Definitions** - 16 operational modes for different development tasks
3. **JIRA Integration** - Deep integration with project management
4. **Git Strategy** - Structured branching and merge procedures
5. **Quality Assurance** - Built-in checks and documentation requirements

## Project Structure After Setup

```
your-project/
├── .guild/
│   ├── Lifecycles/
│   │   ├── GIT-Strategy.md
│   │   ├── LifeCycles.md
│   │   └── MergeEvents.md
│   └── Startup/
│       ├── Details/
│       │   ├── Commands.md
│       │   ├── JiraCommands.md
│       │   ├── ReconcatApplications.md
│       │   ├── ReconcatGuild.md
│       │   ├── Roles.md
│       │   └── SuccessCriteria.md
│       └── FullPlaybooksGuild.md
├── CLAUDE.md
└── .guild-config
```

## Working with AI Assistants

Once Guild is set up in your project:

1. AI assistants like Claude can read the Guild documentation to understand your workflows
2. Use the commands documented in `.guild/Startup/Details/Commands.md`
3. Follow the role definitions in `.guild/Startup/Details/Roles.md`
4. Implement the lifecycle processes in `.guild/Lifecycles/`

## Configuration

Edit `.guild-config` to customize Guild settings for your project. This file contains project-specific configuration that AI assistants will use to understand your development environment.

## Requirements

- Node.js >= 18.0.0
- npm or yarn

## Contributing

Guild is an open-source project. Contributions are welcome!

- Repository: https://github.com/ybotman/ai-guild
- Issues: https://github.com/ybotman/ai-guild/issues

## License

ISC License

## Support

For questions and support:
- GitHub Issues: https://github.com/ybotman/ai-guild/issues
- Documentation: Read the files in `.guild/` after setup

---

Guild - Bringing structure and best practices to AI-assisted development.