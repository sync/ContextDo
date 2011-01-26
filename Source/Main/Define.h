// Timeout Request
#define RequestTimeOutSeconds 30.0

// User Defaults
#define UsernameUserDefaults @"UsernameUserDefaults"
#define PasswordUserDefaults @"PasswordUserDefaults"
#define APITokenUserDefaults @"APITokenUserDefaults"
#define AlertsDistanceWithin @"AlertsDistanceWithin"
#define ShouldUseDevServer @"ShouldUseDevServer"
#define DevServerIp @"DevServerIp"

// Developer
#define APITokenEabled TRUE

// Map View Default span
#define MapViewLocationDefaultSpanInMeters 2000.0
// Update Region if more than 1000 meters
#define RegionShouldUpdateThresholdInMeters 1000.0

// URL
#define BASE_URL ([[NSUserDefaults standardUserDefaults]boolForKey:ShouldUseDevServer]) ? [[NSUserDefaults standardUserDefaults]stringForKey:DevServerIp] : @"http://contextdo.heroku.com"
#define CTXDOURL(base, path) [NSString stringWithFormat:@"%@%@", base, path]
// Login
#define LOGIN_PATH @"/api_token"
// Register
#define REGISTER_PATH @"/users"
// Reset
#define RESET_PASSWORD_PATH @"/users/password"
// Groups
#define GROUPS_PATH @"/groups"
// Group
#define GROUPURL(base, path, groupId) [NSString stringWithFormat:@"%@/%@", CTXDOURL(base, path), groupId]
// Tasks
#define TASKS_PATH @"/tasks"
#define TASKSURL(base, path, groupId) [NSString stringWithFormat:@"%@/groups/%@%@", base, groupId, path]
#define TASKSDUEURL(base, path, due) [NSString stringWithFormat:@"%@?due=%@", CTXDOURL(base, path), due]
#define TASKSWITHINURL(base, path, latitude, longitude, within) [NSString stringWithFormat:@"%@?latitude=%f&longitude=%f&within=%f", CTXDOURL(base, path), latitude, longitude, within]
#define TASKSSEARCHURL(base, path, query) [NSString stringWithFormat:@"%@?q=%@", CTXDOURL(base, path), query]
#define TASKSUPDATEDSINCEURL(base, path, updatedSince) [NSString stringWithFormat:@"%@?updated_since=%@", CTXDOURL(base, path), updatedSince]
// User
#define USER_PATH @"/profile"

// Task
#define TASKURL(base, path, groupId, taskId) [NSString stringWithFormat:@"%@%@%@", GROUPURL(base, path, groupId), TASKS_PATH, ((taskId) ? [NSString stringWithFormat:@"/%@", taskId] : @"")]

// Notifications
#define PlacemarkDidChangeNotification @"PlacemarkDidChangeNotification"
#define UserDidLoginNotification @"UserDidLoginNotification"
#define UserDidRegisterNotification @"UserDidRegisterNotification"
#define UserDidResetPasswordNotification @"UserDidResetPasswordNotification"
#define GroupsDidLoadNotification @"GroupsDidLoadNotification"
#define TasksDidLoadNotification @"TasksDidLoadNotification"
#define TasksDueDidLoadNotification @"TasksDueDidLoadNotification"
#define TasksDueTodayDidLoadNotification @"TasksDueTodayDidLoadNotification"
#define TasksWithinDidLoadNotification @"TasksWithinDidLoadNotification"
#define TasksWithinBackgroundDidLoadNotification @"TasksWithinBackgroundDidLoadNotification"
#define TasksUpdatedSinceDidLoadNotification @"TasksUpdatedSinceDidLoadNotification"
#define TasksSearchDidLoadNotification @"TasksSearchDidLoadNotification"
#define TaskAddNotification @"TaskAddNotification"
#define TaskEditNotification @"TaskEditNotification"
#define TaskDeleteNotification @"TaskDeleteNotification"
#define GroupAddNotification @"GroupAddNotification"
#define GroupEditNotification @"GroupEditNotification"
#define GroupDeleteNotification @"GroupDeleteNotification"
#define UserDidLoadNotification @"UserDidLoadNotification"
#define UserEditNotification @"UserDidLoadNotification"

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
