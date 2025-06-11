#!/bin/bash

# Test script to create a single JIRA ticket from an IFE file

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"
PROJECT_KEY="TIEMPO"

# Test with Issue 1004
FILE="../public/IFE-Tracking/Issues/Current/Issue_1004_SelectVenuesMenuNotWorking.md"

# Read file content
echo "Reading file: $FILE"
echo "---"
head -20 "$FILE"
echo "---"

# Create simple ticket
json_payload='{
  "fields": {
    "project": {
      "key": "'$PROJECT_KEY'"
    },
    "summary": "Issue-1004: Select Venues Menu Not Working",
    "description": "The Select Venues screen in the hamburger menu is not functioning properly. When accessed, it shows no venues and has JavaScript errors.\n\nImported from IFE Tracking System.",
    "issuetype": {
      "name": "Bug"
    },
    "priority": {
      "name": "High"
    }
  }
}'

echo "Creating test ticket..."
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$json_payload" \
    "$JIRA_URL/rest/api/2/issue" | jq '.'