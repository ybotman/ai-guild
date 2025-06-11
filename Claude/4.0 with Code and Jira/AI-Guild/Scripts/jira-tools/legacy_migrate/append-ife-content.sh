#!/bin/bash

# Append full IFE markdown content to JIRA tickets

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Function to append IFE content to ticket
append_ife_content() {
    local ticket_key=$1
    local ife_file=$2
    local ife_number=$3
    local ife_type=$4
    
    if [ ! -f "$ife_file" ]; then
        echo "❌ File not found: $ife_file"
        return
    fi
    
    echo "Appending IFE content to $ticket_key..."
    
    # Read the entire file content
    local file_content=$(cat "$ife_file")
    
    # Escape content for JSON (handle quotes, newlines, etc)
    # Using jq to properly escape the content
    local escaped_content=$(echo "$file_content" | jq -Rs .)
    
    # Create comment with full IFE content
    local comment_json=$(cat <<EOF
{
  "body": "## Full IFE Document Content\n\n---\n\n\`\`\`markdown\n${file_content}\n\`\`\`\n\n---\n\n*Original file: $(basename "$ife_file")*"
}
EOF
)
    
    # Use jq to properly format the JSON with escaped content
    local final_json=$(jq -n \
        --arg body "## Full IFE Document Content

---

\`\`\`markdown
$file_content
\`\`\`

---

*Original file: $(basename "$ife_file")*" \
        '{body: $body}')
    
    # Add comment to JIRA
    local response=$(curl -s -w "\n%{http_code}" -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$final_json" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/comment")
    
    # Extract status code
    local status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "201" ]; then
        echo "✅ Successfully appended IFE content to $ticket_key"
    else
        echo "❌ Failed to append content to $ticket_key (HTTP $status_code)"
        echo "$response" | head -n-1 | jq .
    fi
    
    sleep 0.5
}

# Test function with smaller content first
test_append() {
    local ticket_key=$1
    local test_content="Test IFE Content\n\nThis is a test to ensure proper formatting."
    
    echo "Testing with $ticket_key..."
    
    local test_json=$(jq -n \
        --arg body "## Test Content

\`\`\`markdown
$test_content
\`\`\`" \
        '{body: $body}')
    
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$test_json" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/comment" > /dev/null
    
    echo "✅ Test comment added"
}

# Main execution
echo "Appending IFE content to JIRA tickets..."
echo "======================================="

# Test first
echo "Running test..."
test_append "TIEMPO-2"

echo -e "\nProcessing actual IFE files..."

# Issues - Current
append_ife_content "TIEMPO-2" "../public/IFE-Tracking/Issues/Current/Issue_1004_SelectVenuesMenuNotWorking.md" "1004" "Issue"
append_ife_content "TIEMPO-3" "../public/IFE-Tracking/Issues/Current/Issue_1017_ViewEventVenueDisplayEnhancement.md" "1017" "Issue"
append_ife_content "TIEMPO-4" "../public/IFE-Tracking/Issues/Current/Issue_1019_BuildErrorsAfterESLintFixes.md" "1019" "Issue"

# Issues - Completed (sample)
append_ife_content "TIEMPO-16" "../public/IFE-Tracking/Issues/Completed/Issue_1001_LocationModalMapDots.md" "1001" "Issue"
append_ife_content "TIEMPO-25" "../public/IFE-Tracking/Issues/Completed/Issue_1018_ESLintErrorsCleanup.md" "1018" "Issue"

# Features - Current (sample)
append_ife_content "TIEMPO-36" "../public/IFE-Tracking/Features/Current/Feature_3001_VenueSelectionModal.md" "3001" "Feature"

# Features - Completed (sample)
append_ife_content "TIEMPO-52" "../public/IFE-Tracking/Features/Completed/Feature_3002_DebugMenu.md" "3002" "Feature"

# Epic (sample)
append_ife_content "TIEMPO-56" "../public/IFE-Tracking/Epics/Current/Epic_5003_ServiceLayerArchitecture/Epic_5003_ServiceLayerArchitecture.md" "5003" "Epic"

echo "======================================="
echo "Sample files processed. Run append-all-ife.sh to process all tickets."