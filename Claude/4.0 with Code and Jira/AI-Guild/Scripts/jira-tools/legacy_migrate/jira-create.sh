#!/bin/bash

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Create issue (pass JSON as argument)
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$1" \
  "$JIRA_URL/rest/api/2/issue" | jq '.'
