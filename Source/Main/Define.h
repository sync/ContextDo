// Timeout Request
#define RequestTimeOutSeconds 30.0

// test@test.com
// testtest

// User Defaults
#define UsernameUserDefaults @"UsernameUserDefaults"
#define PasswordUserDefaults @"PasswordUserDefaults"
#define APITokenUserDefaults @"APITokenUserDefaults"

// Developer
#define APITokenEabled TRUE

// Map View Default span
#define MapViewLocationDefaultSpanInMeters 2000.0
// Update Region if more than 1000 meters
#define RegionShouldUpdateThresholdInMeters 1000.0

// URL
// contextdo.heroku.com
#define BASE_URL @"http://contextdo.heroku.com"
#define CTXDOURL(base, path) [NSString stringWithFormat:@"%@%@", base, path]
// Login
#define LOGIN_PATH @"/api_token.json"
// Register
#define REGISTER_PATH @"/users.json"
// Reset
#define RESET_PASSWORD_PATH @"/users/password.json"
// Groups
#define GROUPS_PATH @"/groups.json"
// Task
#define TASKS_PATH @"/tasks.json"
#define TASKSURL(base, path, groupId) [NSString stringWithFormat:@"%@/groups/%@%@", base, groupId, path]

// Notifications
#define PlacemarkDidChangeNotification @"PlacemarkDidChangeNotification"
#define UserDidLoginNotification @"UserDidLoginNotification"
#define UserDidRegisterNotification @"UserDidRegisterNotification"
#define UserDidResetPasswordNotification @"UserDidResetPasswordNotification"
#define GroupsDidLoadNotification @"GroupsDidLoadNotification"
#define TasksDidLoadNotification @"TasksDidLoadNotification"