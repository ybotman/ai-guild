#!/bin/bash

# Update completed IFE tickets with detailed work history

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Function to extract and format work history
process_ife_file() {
    local file=$1
    local ticket_key=$2
    local ife_number=$3
    
    echo "Processing $ticket_key from $file..."
    
    # Read file content
    local content=$(cat "$file")
    
    # Extract key information
    local work_summary=""
    
    # Check for Resolution Log
    if echo "$content" | grep -q "Resolution Log"; then
        work_summary="${work_summary}RESOLUTION LOG:\n"
        work_summary="${work_summary}$(echo "$content" | sed -n '/Resolution Log/,/^##/p' | grep -E "Branch:|Commit:|PR:|Deployed:|Verified:" | sed 's/^/  /')\n\n"
    fi
    
    # Check for Fix Description
    if echo "$content" | grep -q "Fix Description"; then
        work_summary="${work_summary}FIX APPLIED:\n"
        work_summary="${work_summary}$(echo "$content" | sed -n '/Fix Description/,/^##/p' | head -10 | tail -8 | sed 's/^/  /')\n\n"
    fi
    
    # Check for Files Modified
    if echo "$content" | grep -q "Files Modified"; then
        work_summary="${work_summary}FILES MODIFIED:\n"
        work_summary="${work_summary}$(echo "$content" | sed -n '/Files Modified/,/^##/p' | grep -E "^- " | head -10 | sed 's/^/  /')\n\n"
    fi
    
    # Check for Testing section
    if echo "$content" | grep -q "Testing:"; then
        work_summary="${work_summary}TESTING PERFORMED:\n"
        work_summary="${work_summary}$(echo "$content" | sed -n '/Testing:/,/^##/p' | head -5 | tail -3 | sed 's/^/  /')\n\n"
    fi
    
    # Create comprehensive comment
    local comment_json=$(jq -n \
        --arg body "Work History from IFE-$ife_number:

$work_summary
Status: ✅ Completed
Source: $(basename "$file")

[Full details available in IFE tracking system]" \
        '{body: $body}')
    
    # Add comment to JIRA
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$comment_json" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/comment" > /dev/null
    
    echo "  ✓ Added detailed work history"
    
    # Transition to Done
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"transition": {"id": "41"}}' \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions" 2>/dev/null
    
    echo "  ✓ Transitioned to Done"
    sleep 0.5
}

# Process specific completed issues with known detailed history
echo "Updating completed IFEs with detailed work history..."
echo "==================================================="

# Issues with good work history
process_ife_file "../public/IFE-Tracking/Issues/Completed/Issue_1001_LocationModalMapDots.md" "TIEMPO-16" "1001"
process_ife_file "../public/IFE-Tracking/Issues/Completed/Issue_1018_ESLintErrorsCleanup.md" "TIEMPO-25" "1018"
process_ife_file "../public/IFE-Tracking/Issues/Completed/Issue_1024_OrganizerSelectionEmptyForBoston.md" "TIEMPO-26" "1024"
process_ife_file "../public/IFE-Tracking/Issues/Completed/Issue_1027_IPLocationInitializationError.md" "TIEMPO-27" "1027"
process_ife_file "../public/IFE-Tracking/Issues/Completed/Issue_1029_DebugMenuTestProdDeployment.md" "TIEMPO-28" "1029"
process_ife_file "../public/IFE-Tracking/Issues/Completed/Issue_1030_DuplicatePrivacyPolicyMenuItems.md" "TIEMPO-29" "1030"
process_ife_file "../public/IFE-Tracking/Issues/Completed/Issue_1031_RemoveCalendarLocationBar.md" "TIEMPO-30" "1031"

# Features
process_ife_file "../public/IFE-Tracking/Features/Completed/Feature_3002_DebugMenu.md" "TIEMPO-52" "3002"
process_ife_file "../public/IFE-Tracking/Features/Completed/Feature_3014_SimplifyFirebaseAuth.md" "TIEMPO-53" "3014"
process_ife_file "../public/IFE-Tracking/Features/Completed/Feature_3015_ModernSansSerifTypography.md" "TIEMPO-54" "3015"
process_ife_file "../public/IFE-Tracking/Features/Completed/Feature_3016_ExpandableCategoryFilter.md" "TIEMPO-55" "3016"

echo "==================================================="
echo "Detailed update complete!"