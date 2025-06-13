When reading this file:

**1. Check Configuration**
- Verify .guild-config and .jira-config exist in root directory

**2. Display Version**
- Show local AI-Guild version from .guild-config

**3. Quick Version Check**
- Run: `git fetch origin && git status -uno`
- Tell user simply: "Your Guild is up to date" or "Updates available from repository"

Repository URL: https://github.com/ybotman/ai-guild.git


**4. Full Guild Startup**
After version check, complete the startup:
1) Read all Startup/*.md files
2) Read all Playbooks/Lifecycles/*.md files  
3) Inform user: "AI-Guild v[VERSION] ready. To load application-specific playbooks, please specify their location."
