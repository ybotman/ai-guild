#!/bin/bash

# JIRA Startup Check for AI-Guild
# Implements the JIRA standards for checking work status

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"
PROJECT="TIEMPO"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== AI-Guild JIRA Startup Check ===${NC}\n"

# 1. Check for In Progress tickets
echo -e "${YELLOW}1. Checking for In Progress tickets...${NC}"
in_progress=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_URL/rest/api/2/search?jql=project=$PROJECT%20AND%20status='In Progress'&fields=key,summary,assignee" | \
    jq -r '.issues[]')

if [ -n "$in_progress" ]; then
    echo -e "${RED}⚠️  Found In Progress tickets:${NC}"
    echo "$in_progress" | jq -r '"\(.key): \(.fields.summary)"'
    echo -e "\n${YELLOW}Should continue working on these tickets first before taking new work.${NC}"
else
    echo -e "${GREEN}✓ No In Progress tickets found${NC}"
fi

echo

# 2. Check for In Review tickets
echo -e "${YELLOW}2. Checking for In Review tickets...${NC}"
in_review=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_URL/rest/api/2/search?jql=project=$PROJECT%20AND%20status='In Review'&fields=key,summary,updated" | \
    jq -r '.issues[]')

if [ -n "$in_review" ]; then
    echo -e "${BLUE}📋 Found tickets In Review:${NC}"
    echo "$in_review" | jq -r '"\(.key): \(.fields.summary) (Updated: \(.fields.updated | split("T")[0]))"'
    echo -e "\n${YELLOW}User should review these for potential closure.${NC}"
else
    echo -e "${GREEN}✓ No tickets in review${NC}"
fi

echo

# 3. Check To Do queue
echo -e "${YELLOW}3. Checking To Do queue...${NC}"
todo=$(curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_URL/rest/api/2/search?jql=project=$PROJECT%20AND%20status='To Do'%20ORDER%20BY%20priority%20DESC,created%20ASC&fields=key,summary,priority,issuetype" | \
    jq -r '.issues[]')

if [ -n "$todo" ]; then
    echo -e "${GREEN}📝 To Do Queue (prioritized):${NC}"
    echo "$todo" | jq -r '"[\(.fields.priority.name)] \(.key): \(.fields.summary) (\(.fields.issuetype.name))"'
    echo -e "\n${YELLOW}Ready to start work on these tickets.${NC}"
else
    echo -e "${BLUE}ℹ️  To Do queue is empty${NC}"
fi

echo

# 4. Summary
echo -e "${BLUE}=== Summary ===${NC}"
in_progress_count=$(echo "$in_progress" | jq -s 'length')
in_review_count=$(echo "$in_review" | jq -s 'length')
todo_count=$(echo "$todo" | jq -s 'length')

echo "• In Progress: $in_progress_count tickets"
echo "• In Review: $in_review_count tickets"
echo "• To Do: $todo_count tickets"

echo -e "\n${GREEN}=== Next Steps ===${NC}"
if [ "$in_progress_count" -gt 0 ]; then
    echo "1. Continue work on In Progress tickets"
elif [ "$in_review_count" -gt 0 ]; then
    echo "1. Ask user to review tickets for closure"
    echo "2. Pick new work from To Do queue"
elif [ "$todo_count" -gt 0 ]; then
    echo "1. Select ticket from To Do queue to begin work"
else
    echo "1. Wait for user to move tickets from Backlog to To Do"
fi