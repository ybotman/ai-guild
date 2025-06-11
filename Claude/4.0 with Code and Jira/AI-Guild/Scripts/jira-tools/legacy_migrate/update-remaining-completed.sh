#!/bin/bash

# Update remaining completed IFE tickets

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Function to update ticket
update_ticket() {
    local ticket_key=$1
    local ife_number=$2
    
    echo "Updating $ticket_key (IFE-$ife_number)..."
    
    # Add completion comment
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"body\": \"This issue was marked as completed in the IFE Tracking System.\\n\\nStatus: ✅ Completed\\nIFE Number: $ife_number\"}" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/comment" > /dev/null
    
    # Transition to Done (ID 41)
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"transition": {"id": "41"}}' \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions"
    
    echo "  ✓ Updated and transitioned to Done"
    sleep 0.5
}

echo "Updating remaining completed tickets..."
echo "====================================="

# Remaining completed issues
update_ticket "TIEMPO-23" "1009"
update_ticket "TIEMPO-24" "1010"
update_ticket "TIEMPO-31" "1033"
update_ticket "TIEMPO-32" "1034"
update_ticket "TIEMPO-33" "1035"
update_ticket "TIEMPO-34" "1036"
update_ticket "TIEMPO-35" "1038"

echo "====================================="
echo "All completed tickets updated!"