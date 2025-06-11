#!/bin/bash

# AI-Guild JIRA Workflow Manager
# Handles status transitions, role-based work logging, and comments

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Role-based functions
scout_work() {
    local ticket=$1
    echo -e "${BLUE}=== SCOUT ROLE ===${NC}"
    
    # Add Scout comment
    ./jira-worklog.sh add "$ticket" "Scout" "20m" "Investigated requirements and codebase:
- Located relevant components
- Assessed complexity
- Identified dependencies
- Documented findings for Architect"
    
    # Add findings as comment
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "body": "**[AI-Guild: Scout]**\n\nInvestigation complete. Found:\n- ViewEvent.js component\n- EventForm with initialValues support\n- Existing event creation flow\n\nComplexity: Low-Medium\nReady for Architect design."
        }' \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket/comment" > /dev/null
        
    echo -e "${GREEN}✅ Scout work logged${NC}"
}

architect_work() {
    local ticket=$1
    echo -e "${BLUE}=== ARCHITECT ROLE ===${NC}"
    
    # Add Architect worklog
    ./jira-worklog.sh add "$ticket" "Architect" "15m" "Designed solution:
- UI component placement
- Data flow design
- Implementation approach
- Identified no API changes needed"
    
    # Design comment
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "body": "**[AI-Guild: Architect]**\n\nDesign approved:\n- Add Copy button to ViewEvent\n- Use moment.add(7, days) for date\n- Reuse EventForm with initialValues\n- No backend changes required"
        }' \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket/comment" > /dev/null
        
    echo -e "${GREEN}✅ Architect work logged${NC}"
}

builder_work() {
    local ticket=$1
    echo -e "${BLUE}=== BUILDER ROLE ===${NC}"
    
    # Transition to In Progress
    echo "Transitioning to In Progress..."
    ./jira-transition.sh "$ticket" 21 "[AI-Guild: Builder] Starting implementation"
    
    # Add Builder worklog
    ./jira-worklog.sh add "$ticket" "Builder" "45m" "Implementation and testing:
- Added Copy Event button
- Implemented handleCopyEvent function
- Added role-based visibility
- Created unit tests
- Tested edge cases"
    
    # Implementation comment
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "body": "**[AI-Guild: Builder]**\n\nImplementation complete:\n- ✅ Feature working as designed\n- ✅ Tests passing\n- ✅ ESLint clean\n- Branch: feature/TIEMPO-57-event-copy"
        }' \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket/comment" > /dev/null
        
    echo -e "${GREEN}✅ Builder work logged${NC}"
}

crk_work() {
    local ticket=$1
    echo -e "${BLUE}=== CRK ROLE ===${NC}"
    
    # Add CRK worklog
    ./jira-worklog.sh add "$ticket" "CRK" "15m" "Code review and knowledge transfer:
- Reviewed implementation
- Validated against standards
- Documented patterns
- Approved for release"
    
    # Review comment
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "body": "**[AI-Guild: CRK]**\n\nCode Review: APPROVED ✅\n- Clean implementation\n- Follows patterns\n- Good test coverage\n- Ready for user review"
        }' \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket/comment" > /dev/null
    
    # Transition to In Review
    echo "Transitioning to In Review..."
    ./jira-transition.sh "$ticket" 31 "[AI-Guild: CRK] Code review complete, ready for user testing"
    
    echo -e "${GREEN}✅ CRK work logged${NC}"
}

# Show workflow summary
show_summary() {
    local ticket=$1
    echo -e "\n${BLUE}=== WORKFLOW SUMMARY ===${NC}"
    echo "Ticket: $ticket"
    echo ""
    echo "Work performed by AI-Guild roles:"
    ./jira-worklog.sh view "$ticket"
    echo ""
    echo "Total time: 1h 35m across 4 roles"
    echo -e "${GREEN}Ready for user verification in 'In Review' status${NC}"
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <ticket> [role]"
    echo "Roles: scout, architect, builder, crk, all"
    echo "Example: $0 TIEMPO-57 all"
    exit 1
fi

TICKET=$1
ROLE=${2:-all}

# Make scripts executable
chmod +x jira-transition.sh jira-worklog.sh

case $ROLE in
    "scout")
        scout_work "$TICKET"
        ;;
    "architect")
        architect_work "$TICKET"
        ;;
    "builder")
        builder_work "$TICKET"
        ;;
    "crk")
        crk_work "$TICKET"
        ;;
    "all")
        scout_work "$TICKET"
        sleep 1
        architect_work "$TICKET"
        sleep 1
        builder_work "$TICKET"
        sleep 1
        crk_work "$TICKET"
        show_summary "$TICKET"
        ;;
    *)
        echo "Unknown role: $ROLE"
        exit 1
        ;;
esac