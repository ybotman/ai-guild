#!/bin/bash

# Batch IFE to JIRA Migration Script
# This script creates JIRA tickets for all IFE tracking documents

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"
PROJECT_KEY="TIEMPO"

# Counter for progress
CREATED_COUNT=0
FAILED_COUNT=0

# Log file
LOG_FILE="ife-migration-$(date +%Y%m%d-%H%M%S).log"

# Function to log messages
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to create JIRA ticket from IFE file
create_ticket_from_ife() {
    local file=$1
    local filename=$(basename "$file" .md)
    
    # Extract IFE number and type
    local ife_type=""
    local ife_number=""
    local title=""
    
    if [[ $filename =~ (Issue|Feature|Epic)_([0-9]+)_(.*) ]]; then
        ife_type="${BASH_REMATCH[1]}"
        ife_number="${BASH_REMATCH[2]}"
        title="${BASH_REMATCH[3]}"
        # Replace underscores with spaces in title
        title="${title//_/ }"
    else
        log_message "⚠️  Skipping file with unexpected format: $filename"
        return
    fi
    
    # Determine JIRA issue type
    local issue_type="Task"
    case $ife_type in
        "Issue")
            issue_type="Task"
            ;;
        "Feature")
            issue_type="Story"
            ;;
        "Epic")
            issue_type="Epic"
            ;;
    esac
    
    # Check if completed
    local is_completed=false
    [[ $file == *"/Completed/"* ]] && is_completed=true
    
    # Create summary
    local summary="IFE-${ife_number}: $title"
    
    # Extract first section of content for description
    local description="Type: $ife_type\\nIFE Number: $ife_number\\nStatus: "
    if [ "$is_completed" = true ]; then
        description+="Completed\\n"
    else
        description+="In Progress\\n"
    fi
    description+="\\nOriginal File: ${file#../}\\n\\n"
    
    # Add first 30 lines of content
    local content=$(head -30 "$file" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    description+="$content"
    
    # Create JSON payload
    local json_payload=$(cat <<EOF
{
  "fields": {
    "project": {
      "key": "$PROJECT_KEY"
    },
    "summary": "$summary",
    "description": "$description",
    "issuetype": {
      "name": "$issue_type"
    }
  }
}
EOF
)
    
    log_message "Creating ticket for: $summary"
    
    # Create the ticket
    local response=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "$JIRA_URL/rest/api/2/issue")
    
    # Check if successful
    local ticket_key=$(echo "$response" | jq -r '.key // empty')
    
    if [ -n "$ticket_key" ]; then
        log_message "✅ Created: $ticket_key - $summary"
        ((CREATED_COUNT++))
        
        # If completed, add comment noting completion
        if [ "$is_completed" = true ]; then
            local comment_payload='{"body": "This IFE was marked as completed in the tracking system when imported."}'
            curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$comment_payload" \
                -X POST \
                "$JIRA_URL/rest/api/2/issue/$ticket_key/comment" > /dev/null
        fi
    else
        log_message "❌ Failed: $summary"
        log_message "   Error: $(echo "$response" | jq -c .)"
        ((FAILED_COUNT++))
    fi
    
    # Rate limiting
    sleep 0.5
}

# Main execution
log_message "======================================"
log_message "IFE to JIRA Migration"
log_message "Started: $(date)"
log_message "Project: $PROJECT_KEY"
log_message "======================================"

# Base directory
IFE_BASE="../public/IFE-Tracking"

# Process Issues
log_message ""
log_message "Processing Issues..."
log_message "-------------------"

# Current Issues
for file in $IFE_BASE/Issues/Current/*.md; do
    [ -f "$file" ] && create_ticket_from_ife "$file"
done

# Completed Issues
for file in $IFE_BASE/Issues/Completed/*.md; do
    [ -f "$file" ] && create_ticket_from_ife "$file"
done

# Process Features
log_message ""
log_message "Processing Features..."
log_message "--------------------"

# Current Features
for file in $IFE_BASE/Features/Current/*.md; do
    [ -f "$file" ] && create_ticket_from_ife "$file"
done

# Completed Features
for file in $IFE_BASE/Features/Completed/*.md; do
    [ -f "$file" ] && create_ticket_from_ife "$file"
done

# Process Epics
log_message ""
log_message "Processing Epics..."
log_message "------------------"

# Current Epics (including subdirectories)
for file in $IFE_BASE/Epics/Current/*.md $IFE_BASE/Epics/Current/*/*.md; do
    [ -f "$file" ] && create_ticket_from_ife "$file"
done

# Summary
log_message ""
log_message "======================================"
log_message "Migration Complete!"
log_message "Created: $CREATED_COUNT tickets"
log_message "Failed: $FAILED_COUNT tickets"
log_message "Log saved to: $LOG_FILE"
log_message "======================================"