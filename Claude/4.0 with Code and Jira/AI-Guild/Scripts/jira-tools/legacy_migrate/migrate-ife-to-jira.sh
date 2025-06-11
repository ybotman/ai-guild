#!/bin/bash

# JIRA Migration Script for IFE Tracking Documents
# This script reads IFE markdown files and creates corresponding JIRA tickets

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"
PROJECT_KEY="TIEMPO"  # Using TangoTiempo project for these tickets

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to extract title from markdown file
extract_title() {
    local file=$1
    # Extract from filename pattern: Issue_1004_SelectVenuesMenuNotWorking.md
    basename "$file" .md | sed 's/_/ /g' | sed 's/Issue /Issue-/g' | sed 's/Feature /Feature-/g' | sed 's/Epic /Epic-/g'
}

# Function to extract description from markdown file
extract_description() {
    local file=$1
    # Get first 1000 characters of content, preserving markdown formatting
    head -n 50 "$file" | sed 's/"/\\"/g' | tr '\n' '\n'
}

# Function to determine issue type
get_issue_type() {
    local file=$1
    if [[ $file == *"Issue_"* ]]; then
        echo "Task"  # TIEMPO project doesn't have Bug type
    elif [[ $file == *"Feature_"* ]]; then
        echo "Story"
    elif [[ $file == *"Epic_"* ]]; then
        echo "Epic"
    else
        echo "Task"
    fi
}

# Function to determine if completed based on file path
is_completed() {
    local file=$1
    if [[ $file == *"/Completed/"* ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to create JIRA ticket
create_jira_ticket() {
    local file=$1
    local title=$(extract_title "$file")
    local description=$(extract_description "$file")
    local issue_type=$(get_issue_type "$file")
    local completed=$(is_completed "$file")
    
    # Create the JIRA ticket JSON payload
    local json_payload=$(cat <<EOF
{
  "fields": {
    "project": {
      "key": "$PROJECT_KEY"
    },
    "summary": "$title",
    "description": "Imported from IFE Tracking System\\n\\nOriginal File: $file\\n\\n$description\\n\\n[Full details in the original markdown file]",
    "issuetype": {
      "name": "$issue_type"
    }
  }
}
EOF
)
    
    echo -e "${YELLOW}Creating JIRA ticket for: $title${NC}"
    
    # Create the ticket
    response=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "$JIRA_URL/rest/api/2/issue")
    
    # Extract the key from response
    ticket_key=$(echo "$response" | jq -r '.key // empty')
    
    if [ -n "$ticket_key" ]; then
        echo -e "${GREEN}✓ Created ticket: $ticket_key${NC}"
        
        # If completed, transition to Done
        if [ "$completed" == "true" ]; then
            echo -e "${YELLOW}  Marking $ticket_key as Done...${NC}"
            # Get available transitions
            transitions=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
                -H "Accept: application/json" \
                "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions")
            
            # Find the "Done" transition ID (usually something like "Done" or "Closed")
            done_transition_id=$(echo "$transitions" | jq -r '.transitions[] | select(.name == "Done" or .name == "Closed" or .name == "Resolved") | .id' | head -1)
            
            if [ -n "$done_transition_id" ]; then
                # Transition to Done
                curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
                    -H "Content-Type: application/json" \
                    -d "{\"transition\": {\"id\": \"$done_transition_id\"}}" \
                    -X POST \
                    "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions"
                echo -e "${GREEN}  ✓ Marked as Done${NC}"
            else
                echo -e "${RED}  ✗ Could not find Done transition${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ Failed to create ticket${NC}"
        echo "Response: $response"
    fi
    
    # Add delay to avoid rate limiting
    sleep 1
}

# Main execution
echo "Starting IFE to JIRA migration..."
echo "Using project: $PROJECT_KEY"
echo ""

# Base directory for IFE tracking
IFE_BASE="../public/IFE-Tracking"

# Process all IFE files
echo "Processing Current Issues..."
for file in $IFE_BASE/Issues/Current/*.md; do
    [ -f "$file" ] && create_jira_ticket "$file"
done

echo -e "\nProcessing Completed Issues..."
for file in $IFE_BASE/Issues/Completed/*.md; do
    [ -f "$file" ] && create_jira_ticket "$file"
done

echo -e "\nProcessing Current Features..."
for file in $IFE_BASE/Features/Current/*.md; do
    [ -f "$file" ] && create_jira_ticket "$file"
done

echo -e "\nProcessing Completed Features..."
for file in $IFE_BASE/Features/Completed/*.md; do
    [ -f "$file" ] && create_jira_ticket "$file"
done

echo -e "\nProcessing Current Epics..."
for file in $IFE_BASE/Epics/Current/*.md; do
    [ -f "$file" ] && create_jira_ticket "$file"
done

echo -e "\nProcessing Completed Epics..."
for file in $IFE_BASE/Epics/Completed/*.md; do
    [ -f "$file" ] && create_jira_ticket "$file"
done

echo -e "\n${GREEN}Migration complete!${NC}"