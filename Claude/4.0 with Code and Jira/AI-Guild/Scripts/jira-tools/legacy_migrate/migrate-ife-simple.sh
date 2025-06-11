#!/bin/bash

# Simple IFE to JIRA Migration Script
# Creates tickets with basic information only

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"
PROJECT_KEY="TIEMPO"

# Create simple ticket
create_simple_ticket() {
    local ife_type=$1
    local ife_number=$2
    local title=$3
    local is_completed=$4
    
    # Determine JIRA issue type
    local issue_type="Task"
    case $ife_type in
        "Feature")
            issue_type="Story"
            ;;
        "Epic")
            issue_type="Epic"
            ;;
    esac
    
    # Create status text
    local status_text="Current"
    [ "$is_completed" = "true" ] && status_text="Completed"
    
    # Create simple JSON - no complex content
    local json_payload=$(cat <<EOF
{
  "fields": {
    "project": {
      "key": "$PROJECT_KEY"
    },
    "summary": "IFE-${ife_number}: ${title}",
    "description": "Type: ${ife_type}\\nIFE Number: ${ife_number}\\nStatus: ${status_text}\\n\\nMigrated from IFE Tracking System",
    "issuetype": {
      "name": "$issue_type"
    }
  }
}
EOF
)
    
    echo "Creating: IFE-${ife_number} (${ife_type})"
    
    # Create the ticket
    response=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "$JIRA_URL/rest/api/2/issue")
    
    # Check result
    ticket_key=$(echo "$response" | jq -r '.key // empty')
    if [ -n "$ticket_key" ]; then
        echo "✅ Created: $ticket_key"
    else
        echo "❌ Failed"
        echo "$response" | jq .
    fi
    
    sleep 0.5
}

# Process a batch of IFEs
echo "Creating IFE tickets in JIRA..."
echo "================================"

# Current Issues
create_simple_ticket "Issue" "1004" "Select Venues Menu Not Working" "false"
create_simple_ticket "Issue" "1017" "View Event Venue Display Enhancement" "false"
create_simple_ticket "Issue" "1019" "Build Errors After ESLint Fixes" "false"
create_simple_ticket "Issue" "1020" "User Settings Hamburger Menu Crash" "false"
create_simple_ticket "Issue" "1021" "Organizer Selection Filter Not Working" "false"
create_simple_ticket "Issue" "1022" "User Settings Update Notification" "false"
create_simple_ticket "Issue" "1023" "Regional Organizer Settings Update Notification" "false"
create_simple_ticket "Issue" "1025" "Location Context UI Inconsistencies" "false"
create_simple_ticket "Issue" "1026" "Select Input Value Mismatch" "false"
create_simple_ticket "Issue" "1028" "Facebook Google Same Email Auth Conflict" "false"
create_simple_ticket "Issue" "1037" "Calendar Event Display Enhancement" "false"
create_simple_ticket "Issue" "1039" "List View Day Header Format" "false"
create_simple_ticket "Issue" "1040" "List View Event Row Order" "false"
create_simple_ticket "Issue" "1041" "Month View Event Display" "false"

# Completed Issues
create_simple_ticket "Issue" "1001" "Location Modal Map Dots" "true"
create_simple_ticket "Issue" "1002" "Authentication Roles Not Loaded" "true"
create_simple_ticket "Issue" "1003" "Calendar View No Events" "true"
create_simple_ticket "Issue" "1005" "Event Insert Fail Due To Malformed Venue Geolocation" "true"
create_simple_ticket "Issue" "1006" "Event Edit Modal Missing Current Values" "true"
create_simple_ticket "Issue" "1007" "Event Update Fail Due To Empty Object Ids" "true"
create_simple_ticket "Issue" "1008" "GeoLocation And Events Initialization Bugs" "true"
create_simple_ticket "Issue" "1009" "Regional Organizer Settings Not Working" "true"
create_simple_ticket "Issue" "1010" "View Event Edit Delete Role Control" "true"
create_simple_ticket "Issue" "1018" "ESLint Errors Cleanup" "true"
create_simple_ticket "Issue" "1024" "Organizer Selection Empty For Boston" "true"
create_simple_ticket "Issue" "1027" "IP Location Initialization Error" "true"
create_simple_ticket "Issue" "1029" "Debug Menu Test Prod Deployment" "true"
create_simple_ticket "Issue" "1030" "Duplicate Privacy Policy Menu Items" "true"
create_simple_ticket "Issue" "1031" "Remove Calendar Location Bar" "true"
create_simple_ticket "Issue" "1033" "Google Analytics Undefined Id" "true"
create_simple_ticket "Issue" "1034" "Event View Timezone And Category Display" "true"
create_simple_ticket "Issue" "1035" "Anonymous User Submenu Not Bypassed" "true"
create_simple_ticket "Issue" "1036" "List View Time Format Layout" "true"
create_simple_ticket "Issue" "1038" "Custom List 21 Days View" "true"

# Current Features
create_simple_ticket "Feature" "3001" "Venue Selection Modal" "false"
create_simple_ticket "Feature" "3003" "Remove Weekly Calendar View" "false"
create_simple_ticket "Feature" "3004" "Calendar Show Images" "false"
create_simple_ticket "Feature" "3005" "Three Category Circles" "false"
create_simple_ticket "Feature" "3006" "Upcoming Features Menu" "false"
create_simple_ticket "Feature" "3007" "About Calendar Section" "false"
create_simple_ticket "Feature" "3008" "Saved Filters And Settings" "false"
create_simple_ticket "Feature" "3009" "Regional Organizer Photo Approval" "false"
create_simple_ticket "Feature" "3010" "Regional Organizer Paid Tiers" "false"
create_simple_ticket "Feature" "3011" "Named User Paid Tier" "false"
create_simple_ticket "Feature" "3012" "List View Start Today" "false"
create_simple_ticket "Feature" "3013" "Three Month Scrollable View" "false"
create_simple_ticket "Feature" "3017" "Monthly View Formatting Improvements" "false"
create_simple_ticket "Feature" "3018" "Enhanced User Info Display" "false"
create_simple_ticket "Feature" "3019" "Role Based Event Submenu" "false"
create_simple_ticket "Feature" "3020" "Edge Geolocation Beta" "false"

# Completed Features
create_simple_ticket "Feature" "3002" "Debug Menu" "true"
create_simple_ticket "Feature" "3014" "Simplify Firebase Auth" "true"
create_simple_ticket "Feature" "3015" "Modern Sans Serif Typography" "true"
create_simple_ticket "Feature" "3016" "Expandable Category Filter" "true"

# Epics
create_simple_ticket "Epic" "5003" "Service Layer Architecture" "false"

echo "================================"
echo "Migration complete!"