// Timeout Request
#define RequestTimeOutSeconds 35.0

// User Defaults
#define AlertsDistanceWithin @"AlertsDistanceWithin"

// Facebook
#define FacebookApplicationId @"125665877503636"

// Map View Default span
#define MapViewLocationDefaultSpanInMeters 2000.0
// Update Region if more than 1000 meters
#define RegionShouldUpdateThresholdInMeters 1000.0
// High span
#define MapViewLocationDefaultHightSpanInMeters 4000.0

// Notifications
#define PlacemarkDidChangeNotification @"PlacemarkDidChangeNotification"
#define DropboxSyncedNotification @"DropboxSyncedNotification"

#define TodaysTasksPlacholder @"Todays tasks"
#define NearTasksPlacholder @"Near tasks"

#define CURRENT_LOCATION_PLACEHOLDER @"Current Location"

// Cells
typedef enum {
	CTXDOCellPositionSingle,
	CTXDOCellPositionTop,
	CTXDOCellPositionMiddle,
	CTXDOCellPositionBottom
}CTXDOCellPosition;

typedef enum {
	CTXDOCellContextStandard,
	CTXDOCellContextStandardAlternate,
	CTXDOCellContextExpiring,
	CTXDOCellContextLocationAware,
	CTXDOCellContextDue,
	CTXDOCellContextUpatedTasksLight,
	CTXDOCellContextTaskEditInput,
	CTXDOCellContextTaskEdit,
	CTXDOCellContextTaskEditInputMutliLine,
}CTXDOCellContext;
