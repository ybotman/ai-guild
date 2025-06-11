#!/bin/bash

# Append ALL IFE markdown content to JIRA tickets - simplified version

JIRA_TOKEN=$(security find-generic-password -a "$(whoami)" -s "jira-api-token" -w)
JIRA_URL="https://tobybalsley.atlassian.net"
JIRA_EMAIL="toby.balsley@gmail.com"

# Function to append content
append_content() {
    local ticket=$1
    local file=$2
    
    if [ ! -f "$file" ]; then
        echo "Skip $ticket - file not found"
        return
    fi
    
    echo -n "Appending to $ticket... "
    
    # Read and escape content
    local content=$(cat "$file" | head -1000)  # Limit size for safety
    
    # Create JSON payload using jq
    local json=$(jq -n \
        --arg body "## Full IFE Document

\`\`\`markdown
$content
\`\`\`

*Source: $(basename "$file")*" \
        '{body: $body}')
    
    # Post comment
    local status=$(curl -s -o /dev/null -w "%{http_code}" \
        -u "$JIRA_EMAIL:$JIRA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$json" \
        -X POST \
        "$JIRA_URL/rest/api/2/issue/$ticket/comment")
    
    if [ "$status" = "201" ]; then
        echo "✅"
    else
        echo "❌ ($status)"
    fi
    
    sleep 0.3
}

echo "Appending IFE content to all JIRA tickets"
echo "========================================="

# Process all tickets
# Current Issues
append_content "TIEMPO-2" "../public/IFE-Tracking/Issues/Current/Issue_1004_SelectVenuesMenuNotWorking.md"
append_content "TIEMPO-3" "../public/IFE-Tracking/Issues/Current/Issue_1017_ViewEventVenueDisplayEnhancement.md"
append_content "TIEMPO-4" "../public/IFE-Tracking/Issues/Current/Issue_1019_BuildErrorsAfterESLintFixes.md"
append_content "TIEMPO-5" "../public/IFE-Tracking/Issues/Current/Issue_1020_UserSettingsHamburgerMenuCrash.md"
append_content "TIEMPO-6" "../public/IFE-Tracking/Issues/Current/Issue_1021_OrganizerSelectionFilterNotWorking.md"
append_content "TIEMPO-7" "../public/IFE-Tracking/Issues/Current/Issue_1022_UserSettingsUpdateNotification.md"
append_content "TIEMPO-8" "../public/IFE-Tracking/Issues/Current/Issue_1023_RegionalOrganizerSettingsUpdateNotification.md"
append_content "TIEMPO-9" "../public/IFE-Tracking/Issues/Current/Issue_1025_LocationContextUIInconsistencies.md"
append_content "TIEMPO-10" "../public/IFE-Tracking/Issues/Current/Issue_1026_SelectInputValueMismatch.md"
append_content "TIEMPO-11" "../public/IFE-Tracking/Issues/Current/Issue_1028_FacebookGoogleSameEmailAuthConflict.md"
append_content "TIEMPO-12" "../public/IFE-Tracking/Issues/Current/Issue_1037_CalendarEventDisplayEnhancement.md"
append_content "TIEMPO-13" "../public/IFE-Tracking/Issues/Current/Issue_1039_ListViewDayHeaderFormat.md"
append_content "TIEMPO-14" "../public/IFE-Tracking/Issues/Current/Issue_1040_ListViewEventRowOrder.md"
append_content "TIEMPO-15" "../public/IFE-Tracking/Issues/Current/Issue_1041_MonthViewEventDisplay.md"

# Completed Issues
append_content "TIEMPO-16" "../public/IFE-Tracking/Issues/Completed/Issue_1001_LocationModalMapDots.md"
append_content "TIEMPO-17" "../public/IFE-Tracking/Issues/Completed/Issue_1002_AuthenticationRolesNotLoaded.md"
append_content "TIEMPO-18" "../public/IFE-Tracking/Issues/Completed/Issue_1003_CalendarViewNoEvents.md"
append_content "TIEMPO-19" "../public/IFE-Tracking/Issues/Completed/Issue_1005_EventInsertFailDueToMalformedVenueGeolocation.md"
append_content "TIEMPO-20" "../public/IFE-Tracking/Issues/Completed/Issue_1006_EventEditModalMissingCurrentValues.md"
append_content "TIEMPO-21" "../public/IFE-Tracking/Issues/Completed/Issue_1007_EventUpdateFailDueToEmptyObjectIds.md"
append_content "TIEMPO-22" "../public/IFE-Tracking/Issues/Completed/Issue_1008_GeoLocationAndEventsInitializationBugs.md"
append_content "TIEMPO-23" "../public/IFE-Tracking/Issues/Completed/Issue_1009_RegionalOrganizerSettingsNotWorking.md"
append_content "TIEMPO-24" "../public/IFE-Tracking/Issues/Completed/Issue_1010_ViewEventEditDeleteRoleControl.md"
append_content "TIEMPO-25" "../public/IFE-Tracking/Issues/Completed/Issue_1018_ESLintErrorsCleanup.md"
append_content "TIEMPO-26" "../public/IFE-Tracking/Issues/Completed/Issue_1024_OrganizerSelectionEmptyForBoston.md"
append_content "TIEMPO-27" "../public/IFE-Tracking/Issues/Completed/Issue_1027_IPLocationInitializationError.md"
append_content "TIEMPO-28" "../public/IFE-Tracking/Issues/Completed/Issue_1029_DebugMenuTestProdDeployment.md"
append_content "TIEMPO-29" "../public/IFE-Tracking/Issues/Completed/Issue_1030_DuplicatePrivacyPolicyMenuItems.md"
append_content "TIEMPO-30" "../public/IFE-Tracking/Issues/Completed/Issue_1031_RemoveCalendarLocationBar.md"
append_content "TIEMPO-31" "../public/IFE-Tracking/Issues/Completed/Issue_1033_GoogleAnalyticsUndefinedId.md"
append_content "TIEMPO-32" "../public/IFE-Tracking/Issues/Completed/Issue_1034_EventViewTimezoneAndCategoryDisplay.md"
append_content "TIEMPO-33" "../public/IFE-Tracking/Issues/Completed/Issue_1035_AnonymousUserSubmenuNotBypassed.md"
append_content "TIEMPO-34" "../public/IFE-Tracking/Issues/Completed/Issue_1036_ListViewTimeFormatLayout.md"
append_content "TIEMPO-35" "../public/IFE-Tracking/Issues/Completed/Issue_1038_CustomList21DaysView.md"

# Current Features
append_content "TIEMPO-36" "../public/IFE-Tracking/Features/Current/Feature_3001_VenueSelectionModal.md"
append_content "TIEMPO-37" "../public/IFE-Tracking/Features/Current/Feature_3003_RemoveWeeklyCalendarView.md"
append_content "TIEMPO-38" "../public/IFE-Tracking/Features/Current/Feature_3004_CalendarShowImages.md"
append_content "TIEMPO-39" "../public/IFE-Tracking/Features/Current/Feature_3005_ThreeCategoryCircles.md"
append_content "TIEMPO-40" "../public/IFE-Tracking/Features/Current/Feature_3006_UpcomingFeaturesMenu.md"
append_content "TIEMPO-41" "../public/IFE-Tracking/Features/Current/Feature_3007_AboutCalendarSection.md"
append_content "TIEMPO-42" "../public/IFE-Tracking/Features/Current/Feature_3008_SavedFiltersAndSettings.md"
append_content "TIEMPO-43" "../public/IFE-Tracking/Features/Current/Feature_3009_RegionalOrganizerPhotoApproval.md"
append_content "TIEMPO-44" "../public/IFE-Tracking/Features/Current/Feature_3010_RegionalOrganizerPaidTiers.md"
append_content "TIEMPO-45" "../public/IFE-Tracking/Features/Current/Feature_3011_NamedUserPaidTier.md"
append_content "TIEMPO-46" "../public/IFE-Tracking/Features/Current/Feature_3012_ListViewStartToday.md"
append_content "TIEMPO-47" "../public/IFE-Tracking/Features/Current/Feature_3013_ThreeMonthScrollableView.md"
append_content "TIEMPO-48" "../public/IFE-Tracking/Features/Current/Feature_3017_MonthlyViewFormattingImprovements.md"
append_content "TIEMPO-49" "../public/IFE-Tracking/Features/Current/Feature_3018_EnhancedUserInfoDisplay.md"
append_content "TIEMPO-50" "../public/IFE-Tracking/Features/Current/Feature_3019_RoleBasedEventSubmenu.md"
append_content "TIEMPO-51" "../public/IFE-Tracking/Features/Current/Feature_3020_EdgeGeolocationBeta.md"

# Completed Features
append_content "TIEMPO-52" "../public/IFE-Tracking/Features/Completed/Feature_3002_DebugMenu.md"
append_content "TIEMPO-53" "../public/IFE-Tracking/Features/Completed/Feature_3014_SimplifyFirebaseAuth.md"
append_content "TIEMPO-54" "../public/IFE-Tracking/Features/Completed/Feature_3015_ModernSansSerifTypography.md"
append_content "TIEMPO-55" "../public/IFE-Tracking/Features/Completed/Feature_3016_ExpandableCategoryFilter.md"

# Epic
append_content "TIEMPO-56" "../public/IFE-Tracking/Epics/Current/Epic_5003_ServiceLayerArchitecture/Epic_5003_ServiceLayerArchitecture.md"

echo "========================================="
echo "Complete!"