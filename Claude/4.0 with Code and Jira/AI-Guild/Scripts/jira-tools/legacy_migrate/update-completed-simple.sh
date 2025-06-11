#!/bin/bash

# Simple script to update completed IFE tickets and transition to Done

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Function to add work history comment and transition
update_and_close_ticket() {
    local ticket_key=$1
    local ife_number=$2
    local ife_type=$3
    
    echo "Processing $ticket_key (IFE-$ife_number)..."
    
    # Add a simple work history comment
    local comment_body="This ${ife_type} was completed in the IFE Tracking System.\n\nStatus: ✅ Completed\nIFE Number: ${ife_number}\n\nFor detailed work history, please refer to the original IFE tracking file."
    
    # Create JSON payload for comment
    local json_comment=$(cat <<EOF
{
  "body": "$comment_body"
}
EOF
)
    
    # Add comment
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$json_comment" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/comment" > /dev/null
    
    echo "  ✓ Added completion comment"
    
    # Get transitions
    transitions=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Accept: application/json" \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions")
    
    # Extract transition names and IDs
    echo "$transitions" | jq -r '.transitions[] | "\(.id): \(.name)"'
    
    # Try to find a "Done" transition (checking various names)
    done_id=$(echo "$transitions" | jq -r '.transitions[] | select(.name | test("Done|Closed|Complete|Completed|Resolved"; "i")) | .id' | head -1)
    
    if [ -n "$done_id" ]; then
        # Transition to Done
        curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"transition\": {\"id\": \"$done_id\"}}" \
            -X POST \
            "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions"
        echo "  ✓ Transitioned to Done"
    else
        echo "  ! No Done transition found"
    fi
    
    sleep 0.5
}

# Main execution
echo "Updating completed IFE tickets..."
echo "================================"

# Completed Issues
update_and_close_ticket "TIEMPO-16" "1001" "Issue"
update_and_close_ticket "TIEMPO-17" "1002" "Issue"
update_and_close_ticket "TIEMPO-18" "1003" "Issue"
update_and_close_ticket "TIEMPO-19" "1005" "Issue"
update_and_close_ticket "TIEMPO-20" "1006" "Issue"
update_and_close_ticket "TIEMPO-21" "1007" "Issue"
update_and_close_ticket "TIEMPO-22" "1008" "Issue"
update_and_close_ticket "TIEMPO-23" "1009" "Issue"
update_and_close_ticket "TIEMPO-24" "1010" "Issue"
update_and_close_ticket "TIEMPO-25" "1018" "Issue"
update_and_close_ticket "TIEMPO-26" "1024" "Issue"
update_and_close_ticket "TIEMPO-27" "1027" "Issue"
update_and_close_ticket "TIEMPO-28" "1029" "Issue"
update_and_close_ticket "TIEMPO-29" "1030" "Issue"
update_and_close_ticket "TIEMPO-30" "1031" "Issue"
update_and_close_ticket "TIEMPO-31" "1033" "Issue"
update_and_close_ticket "TIEMPO-32" "1034" "Issue"
update_and_close_ticket "TIEMPO-33" "1035" "Issue"
update_and_close_ticket "TIEMPO-34" "1036" "Issue"
update_and_close_ticket "TIEMPO-35" "1038" "Issue"

# Completed Features
update_and_close_ticket "TIEMPO-52" "3002" "Feature"
update_and_close_ticket "TIEMPO-53" "3014" "Feature"
update_and_close_ticket "TIEMPO-54" "3015" "Feature"
update_and_close_ticket "TIEMPO-55" "3016" "Feature"

echo "================================"
echo "Update complete!"