#!/bin/bash

# Update completed IFE tickets with work history and transition to Done

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Map of IFE numbers to JIRA ticket keys (completed issues)
declare -A COMPLETED_ISSUES=(
    ["1001"]="TIEMPO-16"
    ["1002"]="TIEMPO-17"
    ["1003"]="TIEMPO-18"
    ["1005"]="TIEMPO-19"
    ["1006"]="TIEMPO-20"
    ["1007"]="TIEMPO-21"
    ["1008"]="TIEMPO-22"
    ["1009"]="TIEMPO-23"
    ["1010"]="TIEMPO-24"
    ["1018"]="TIEMPO-25"
    ["1024"]="TIEMPO-26"
    ["1027"]="TIEMPO-27"
    ["1029"]="TIEMPO-28"
    ["1030"]="TIEMPO-29"
    ["1031"]="TIEMPO-30"
    ["1033"]="TIEMPO-31"
    ["1034"]="TIEMPO-32"
    ["1035"]="TIEMPO-33"
    ["1036"]="TIEMPO-34"
    ["1038"]="TIEMPO-35"
)

# Completed features
declare -A COMPLETED_FEATURES=(
    ["3002"]="TIEMPO-52"
    ["3014"]="TIEMPO-53"
    ["3015"]="TIEMPO-54"
    ["3016"]="TIEMPO-55"
)

# Function to extract work history from IFE file
extract_work_history() {
    local file=$1
    local ife_number=$2
    
    echo "Processing $file..."
    
    # Extract key sections (simplified for reliable extraction)
    local work_history=""
    
    # Look for Resolution/Fix sections
    if grep -q "Resolution Log" "$file"; then
        work_history+="## Resolution Log\n"
        sed -n '/Resolution Log/,/^##/p' "$file" | head -n -1 | tail -n +2 > /tmp/resolution.txt
        while IFS= read -r line; do
            work_history+="$line\n"
        done < /tmp/resolution.txt
    fi
    
    # Look for Fix Description
    if grep -q "Fix Description" "$file"; then
        work_history+="\n## Fix Description\n"
        sed -n '/Fix Description/,/^##/p' "$file" | head -n -1 | tail -n +2 > /tmp/fix.txt
        while IFS= read -r line; do
            work_history+="$line\n"
        done < /tmp/fix.txt
    fi
    
    # Look for Implementation
    if grep -q "Implementation" "$file"; then
        work_history+="\n## Implementation Details\n"
        sed -n '/Implementation/,/^##/p' "$file" | head -n -1 | tail -n +2 > /tmp/impl.txt
        while IFS= read -r line; do
            work_history+="$line\n"
        done < /tmp/impl.txt
    fi
    
    # Look for Testing
    if grep -q "Testing" "$file"; then
        work_history+="\n## Testing\n"
        sed -n '/Testing/,/^##/p' "$file" | head -n -1 | tail -n +2 > /tmp/test.txt
        while IFS= read -r line; do
            work_history+="$line\n"
        done < /tmp/test.txt
    fi
    
    echo "$work_history"
}

# Function to update JIRA ticket
update_jira_ticket() {
    local ticket_key=$1
    local ife_number=$2
    local ife_type=$3
    local file_path=$4
    
    echo "Updating $ticket_key (IFE-$ife_number)..."
    
    # Extract work history
    local work_history=$(extract_work_history "$file_path" "$ife_number")
    
    # Create comment with work history
    local comment="Work History from IFE Tracking:\n\n$work_history\n\nImported from: $file_path"
    
    # Escape for JSON
    comment=$(echo -e "$comment" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    
    # Add comment to ticket
    curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"body\": \"$comment\"}" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/comment" > /dev/null
    
    echo "✅ Added work history to $ticket_key"
    
    # Get available transitions
    transitions=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Accept: application/json" \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions")
    
    # Find Done transition
    done_id=$(echo "$transitions" | jq -r '.transitions[] | select(.name == "Done" or .name == "Closed" or .name == "Complete") | .id' | head -1)
    
    if [ -n "$done_id" ]; then
        # Transition to Done
        curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"transition\": {\"id\": \"$done_id\"}}" \
            -X POST \
            "$JIRA_URL/rest/api/2/issue/$ticket_key/transitions"
        echo "✅ Transitioned $ticket_key to Done"
    else
        echo "⚠️  Could not find Done transition for $ticket_key"
    fi
    
    sleep 1
}

# Main execution
echo "Updating completed IFE tickets with work history..."
echo "=================================================="

# Process completed issues
for ife_number in "${!COMPLETED_ISSUES[@]}"; do
    ticket_key="${COMPLETED_ISSUES[$ife_number]}"
    file_path="../public/IFE-Tracking/Issues/Completed/Issue_${ife_number}_*.md"
    file=$(ls $file_path 2>/dev/null | head -1)
    
    if [ -f "$file" ]; then
        update_jira_ticket "$ticket_key" "$ife_number" "Issue" "$file"
    else
        echo "⚠️  File not found for Issue $ife_number"
    fi
done

# Process completed features
for ife_number in "${!COMPLETED_FEATURES[@]}"; do
    ticket_key="${COMPLETED_FEATURES[$ife_number]}"
    file_path="../public/IFE-Tracking/Features/Completed/Feature_${ife_number}_*.md"
    file=$(ls $file_path 2>/dev/null | head -1)
    
    if [ -f "$file" ]; then
        update_jira_ticket "$ticket_key" "$ife_number" "Feature" "$file"
    else
        echo "⚠️  File not found for Feature $ife_number"
    fi
done

echo "=================================================="
echo "Update complete!"