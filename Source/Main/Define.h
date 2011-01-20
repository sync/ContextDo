// Timeout Request
#define RequestTimeOutSeconds 30.0

// User Defaults
#define UsernameUserDefaults @"UsernameUserDefaults"
#define PasswordUserDefaults @"PasswordUserDefaults"
#define APITokenUserDefaults @"APITokenUserDefaults"
#define ShouldResetCredentialsAtStartup @"ShouldResetCredentialsAtStartup"
#define ShouldUseDevServer @"ShouldUseDevServer"
#define DevServerIp @"DevServerIp"

// Developer
#define APITokenEabled TRUE

// Map View Default span
#define MapViewLocationDefaultSpanInMeters 2000.0
// Update Region if more than 1000 meters
#define RegionShouldUpdateThresholdInMeters 1000.0

// URL
// contextdo.heroku.com
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
#define TASKSURL(base, path, groupId, page, perPage) [NSString stringWithFormat:@"%@/groups/%@%@?page=%d&per_page=%d", base, groupId, path, page, perPage]
#define TASKSDUEURL(base, path, due, page, perPage) [NSString stringWithFormat:@"%@?due=%@&page=%d&per_page=%d", CTXDOURL(base, path), due, page, perPage]
#define TASKSWITHINURL(base, path, latitude, longitude, within, perPage) [NSString stringWithFormat:@"%@?latitude=%f&longitude=%f&within=%f&per_page=%d", CTXDOURL(base, path), latitude, longitude, within, perPage]
// Task
#define TASKURL(base, path, taskId) [NSString stringWithFormat:@"%@/%@", CTXDOURL(base, path), taskId]

// Notifications
#define PlacemarkDidChangeNotification @"PlacemarkDidChangeNotification"
#define UserDidLoginNotification @"UserDidLoginNotification"
#define UserDidRegisterNotification @"UserDidRegisterNotification"
#define UserDidResetPasswordNotification @"UserDidResetPasswordNotification"
#define GroupsDidLoadNotification @"GroupsDidLoadNotification"
#define TasksDidLoadNotification @"TasksDidLoadNotification"
#define TasksDueDidLoadNotification @"TasksDueDidLoadNotification"
#define TasksWithinDidLoadNotification @"TasksWithinDidLoadNotification"
#define TaskAddNotification @"TaskAddNotification"
#define TaskEditNotification @"TaskEditNotification"
#define TaskDeleteNotification @"TaskDeleteNotification"
#define GroupAddNotification @"GroupAddNotification"
#define GroupEditNotification @"GroupEditNotification"
#define GroupDeleteNotification @"GroupDeleteNotification"

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
	CTXDOCellContextDueLight
}CTXDOCellContext;
