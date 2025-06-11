#!/bin/bash

# Append ALL IFE markdown content to their respective JIRA tickets

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Counters
SUCCESS_COUNT=0
FAIL_COUNT=0

# Function to append IFE content to ticket
append_ife_content() {
    local ticket_key=$1
    local ife_file=$2
    
    if [ ! -f "$ife_file" ]; then
        echo "❌ File not found: $ife_file"
        ((FAIL_COUNT++))
        return
    fi
    
    echo -n "Appending to $ticket_key from $(basename "$ife_file")... "
    
    # Read file content and escape for JSON
    local file_content=$(cat "$ife_file")
    
    # Create JSON with properly escaped content
    local comment_json=$(jq -n \
        --arg body "## Full IFE Document Content

---

\`\`\`markdown
$file_content
\`\`\`

---

*Original file: $(basename "$ife_file")*
*Imported: $(date)*" \
        '{body: $body}')
    
    # Add comment to JIRA
    local response=$(curl -s -w "\n%{http_code}" -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$comment_json" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket_key/comment")
    
    local status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "201" ]; then
        echo "✅"
        ((SUCCESS_COUNT++))
    else
        echo "❌ (HTTP $status_code)"
        ((FAIL_COUNT++))
    fi
    
    sleep 0.3
}

# Main execution
echo "Appending ALL IFE content to JIRA tickets"
echo "========================================="
echo "Starting at $(date)"
echo

# All IFE to JIRA mappings
declare -A IFE_MAPPINGS=(
    # Current Issues
    ["TIEMPO-2"]="../public/IFE-Tracking/Issues/Current/Issue_1004_SelectVenuesMenuNotWorking.md"
    ["TIEMPO-3"]="../public/IFE-Tracking/Issues/Current/Issue_1017_ViewEventVenueDisplayEnhancement.md"
    ["TIEMPO-4"]="../public/IFE-Tracking/Issues/Current/Issue_1019_BuildErrorsAfterESLintFixes.md"
    ["TIEMPO-5"]="../public/IFE-Tracking/Issues/Current/Issue_1020_UserSettingsHamburgerMenuCrash.md"
    ["TIEMPO-6"]="../public/IFE-Tracking/Issues/Current/Issue_1021_OrganizerSelectionFilterNotWorking.md"
    ["TIEMPO-7"]="../public/IFE-Tracking/Issues/Current/Issue_1022_UserSettingsUpdateNotification.md"
    ["TIEMPO-8"]="../public/IFE-Tracking/Issues/Current/Issue_1023_RegionalOrganizerSettingsUpdateNotification.md"
    ["TIEMPO-9"]="../public/IFE-Tracking/Issues/Current/Issue_1025_LocationContextUIInconsistencies.md"
    ["TIEMPO-10"]="../public/IFE-Tracking/Issues/Current/Issue_1026_SelectInputValueMismatch.md"
    ["TIEMPO-11"]="../public/IFE-Tracking/Issues/Current/Issue_1028_FacebookGoogleSameEmailAuthConflict.md"
    ["TIEMPO-12"]="../public/IFE-Tracking/Issues/Current/Issue_1037_CalendarEventDisplayEnhancement.md"
    ["TIEMPO-13"]="../public/IFE-Tracking/Issues/Current/Issue_1039_ListViewDayHeaderFormat.md"
    ["TIEMPO-14"]="../public/IFE-Tracking/Issues/Current/Issue_1040_ListViewEventRowOrder.md"
    ["TIEMPO-15"]="../public/IFE-Tracking/Issues/Current/Issue_1041_MonthViewEventDisplay.md"
    
    # Completed Issues
    ["TIEMPO-16"]="../public/IFE-Tracking/Issues/Completed/Issue_1001_LocationModalMapDots.md"
    ["TIEMPO-17"]="../public/IFE-Tracking/Issues/Completed/Issue_1002_AuthenticationRolesNotLoaded.md"
    ["TIEMPO-18"]="../public/IFE-Tracking/Issues/Completed/Issue_1003_CalendarViewNoEvents.md"
    ["TIEMPO-19"]="../public/IFE-Tracking/Issues/Completed/Issue_1005_EventInsertFailDueToMalformedVenueGeolocation.md"
    ["TIEMPO-20"]="../public/IFE-Tracking/Issues/Completed/Issue_1006_EventEditModalMissingCurrentValues.md"
    ["TIEMPO-21"]="../public/IFE-Tracking/Issues/Completed/Issue_1007_EventUpdateFailDueToEmptyObjectIds.md"
    ["TIEMPO-22"]="../public/IFE-Tracking/Issues/Completed/Issue_1008_GeoLocationAndEventsInitializationBugs.md"
    ["TIEMPO-23"]="../public/IFE-Tracking/Issues/Completed/Issue_1009_RegionalOrganizerSettingsNotWorking.md"
    ["TIEMPO-24"]="../public/IFE-Tracking/Issues/Completed/Issue_1010_ViewEventEditDeleteRoleControl.md"
    ["TIEMPO-25"]="../public/IFE-Tracking/Issues/Completed/Issue_1018_ESLintErrorsCleanup.md"
    ["TIEMPO-26"]="../public/IFE-Tracking/Issues/Completed/Issue_1024_OrganizerSelectionEmptyForBoston.md"
    ["TIEMPO-27"]="../public/IFE-Tracking/Issues/Completed/Issue_1027_IPLocationInitializationError.md"
    ["TIEMPO-28"]="../public/IFE-Tracking/Issues/Completed/Issue_1029_DebugMenuTestProdDeployment.md"
    ["TIEMPO-29"]="../public/IFE-Tracking/Issues/Completed/Issue_1030_DuplicatePrivacyPolicyMenuItems.md"
    ["TIEMPO-30"]="../public/IFE-Tracking/Issues/Completed/Issue_1031_RemoveCalendarLocationBar.md"
    ["TIEMPO-31"]="../public/IFE-Tracking/Issues/Completed/Issue_1033_GoogleAnalyticsUndefinedId.md"
    ["TIEMPO-32"]="../public/IFE-Tracking/Issues/Completed/Issue_1034_EventViewTimezoneAndCategoryDisplay.md"
    ["TIEMPO-33"]="../public/IFE-Tracking/Issues/Completed/Issue_1035_AnonymousUserSubmenuNotBypassed.md"
    ["TIEMPO-34"]="../public/IFE-Tracking/Issues/Completed/Issue_1036_ListViewTimeFormatLayout.md"
    ["TIEMPO-35"]="../public/IFE-Tracking/Issues/Completed/Issue_1038_CustomList21DaysView.md"
    
    # Current Features
    ["TIEMPO-36"]="../public/IFE-Tracking/Features/Current/Feature_3001_VenueSelectionModal.md"
    ["TIEMPO-37"]="../public/IFE-Tracking/Features/Current/Feature_3003_RemoveWeeklyCalendarView.md"
    ["TIEMPO-38"]="../public/IFE-Tracking/Features/Current/Feature_3004_CalendarShowImages.md"
    ["TIEMPO-39"]="../public/IFE-Tracking/Features/Current/Feature_3005_ThreeCategoryCircles.md"
    ["TIEMPO-40"]="../public/IFE-Tracking/Features/Current/Feature_3006_UpcomingFeaturesMenu.md"
    ["TIEMPO-41"]="../public/IFE-Tracking/Features/Current/Feature_3007_AboutCalendarSection.md"
    ["TIEMPO-42"]="../public/IFE-Tracking/Features/Current/Feature_3008_SavedFiltersAndSettings.md"
    ["TIEMPO-43"]="../public/IFE-Tracking/Features/Current/Feature_3009_RegionalOrganizerPhotoApproval.md"
    ["TIEMPO-44"]="../public/IFE-Tracking/Features/Current/Feature_3010_RegionalOrganizerPaidTiers.md"
    ["TIEMPO-45"]="../public/IFE-Tracking/Features/Current/Feature_3011_NamedUserPaidTier.md"
    ["TIEMPO-46"]="../public/IFE-Tracking/Features/Current/Feature_3012_ListViewStartToday.md"
    ["TIEMPO-47"]="../public/IFE-Tracking/Features/Current/Feature_3013_ThreeMonthScrollableView.md"
    ["TIEMPO-48"]="../public/IFE-Tracking/Features/Current/Feature_3017_MonthlyViewFormattingImprovements.md"
    ["TIEMPO-49"]="../public/IFE-Tracking/Features/Current/Feature_3018_EnhancedUserInfoDisplay.md"
    ["TIEMPO-50"]="../public/IFE-Tracking/Features/Current/Feature_3019_RoleBasedEventSubmenu.md"
    ["TIEMPO-51"]="../public/IFE-Tracking/Features/Current/Feature_3020_EdgeGeolocationBeta.md"
    
    # Completed Features
    ["TIEMPO-52"]="../public/IFE-Tracking/Features/Completed/Feature_3002_DebugMenu.md"
    ["TIEMPO-53"]="../public/IFE-Tracking/Features/Completed/Feature_3014_SimplifyFirebaseAuth.md"
    ["TIEMPO-54"]="../public/IFE-Tracking/Features/Completed/Feature_3015_ModernSansSerifTypography.md"
    ["TIEMPO-55"]="../public/IFE-Tracking/Features/Completed/Feature_3016_ExpandableCategoryFilter.md"
    
    # Epic
    ["TIEMPO-56"]="../public/IFE-Tracking/Epics/Current/Epic_5003_ServiceLayerArchitecture/Epic_5003_ServiceLayerArchitecture.md"
)

# Process all mappings
for ticket_key in "${!IFE_MAPPINGS[@]}"; do
    ife_file="${IFE_MAPPINGS[$ticket_key]}"
    append_ife_content "$ticket_key" "$ife_file"
done | sort

echo
echo "========================================="
echo "Completed at $(date)"
echo "Success: $SUCCESS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "========================================="