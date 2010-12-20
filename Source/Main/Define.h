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
#define LOGIN_PATH @"/api_token.json"
// Register
#define REGISTER_PATH @"/users.json"
// Reset
#define RESET_PASSWORD_PATH @"/users/password.json"
// Groups
#define GROUPS_PATH @"/groups.json"
#define GROUPSURL(base, path, page) [NSString stringWithFormat:@"%@?page=%d", CTXDOURL(base, path), page]
// Task
#define TASKS_PATH @"/tasks.json"
#define TASKSURL(base, path, groupId, page) [NSString stringWithFormat:@"%@/groups/%@%@?page=%d", base, groupId, path, page]
#define TASKSDUEURL(base, path, due, page) [NSString stringWithFormat:@"%@?due=%@&page=%d", CTXDOURL(base, path), due, page]

// Notifications
#define PlacemarkDidChangeNotification @"PlacemarkDidChangeNotification"
#define UserDidLoginNotification @"UserDidLoginNotification"
#define UserDidRegisterNotification @"UserDidRegisterNotification"
#define UserDidResetPasswordNotification @"UserDidResetPasswordNotification"
#define GroupsDidLoadNotification @"GroupsDidLoadNotification"
#define TasksDidLoadNotification @"TasksDidLoadNotification"
#define TasksDueDidLoadNotification @"TasksDueDidLoadNotification"