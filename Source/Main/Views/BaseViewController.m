#import "BaseViewController.h"
#import "Reachability.h"

@implementation BaseViewController

@synthesize loadingView, noResultsView;

#pragma mark -
#pragma mark Initialisation

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder 
{
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self setupNavigationBar];
	[self setupToolbar];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFix) name:GPSLocationDidFix object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidStop) name:GPSLocationDidStop object:nil];
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	
}

- (void)setupToolbar
{
	
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	[self.noResultsView hide:FALSE];
	
	if (!self.loadingView) {
		self.loadingView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.loadingView.delegate = self;
		[self.view addSubview:self.loadingView];
		[self.view bringSubviewToFront:self.loadingView];
		[self.loadingView show:TRUE];
	}
	self.loadingView.labelText = @"Loading";
}

- (void)baseLoadingViewCenterDidStopForKey:(NSString *)key
{
	[self.loadingView hide:TRUE];
}

- (void)baseLoadingViewCenterShowErrorMsg:(NSString *)errorMsg forKey:(NSString *)key;
{
	[self.loadingView hide:FALSE];
	
	if (!self.noResultsView) {
		self.noResultsView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.noResultsView.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];
		self.noResultsView.labelText = errorMsg;
		self.noResultsView.mode = MBProgressHUDModeCustomView;
		self.noResultsView.delegate = self;
		[self.view addSubview:self.noResultsView];
		[self.view bringSubviewToFront:self.noResultsView];
		[self.noResultsView show:TRUE];
		[self performSelector:@selector(baseLoadingViewCenterRemoveErrorMsgForKey:) withObject:key afterDelay:1.5];
	}
}

- (void)baseLoadingViewCenterShowErrorMsg:(NSString *)errorMsg details:(NSString *)details forKey:(NSString *)key
{
	[self.loadingView hide:FALSE];
	
	if (!self.noResultsView) {
		self.noResultsView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.noResultsView.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];
		self.noResultsView.labelText = errorMsg;
		self.noResultsView.detailsLabelText = details;
		self.noResultsView.mode = MBProgressHUDModeCustomView;
		self.noResultsView.delegate = self;
		[self.view addSubview:self.noResultsView];
		[self.view bringSubviewToFront:self.noResultsView];
		[self.noResultsView show:TRUE];
		[self performSelector:@selector(baseLoadingViewCenterRemoveErrorMsgForKey:) withObject:key afterDelay:1.5];
	}
}

- (void)baseLoadingViewCenterRemoveErrorMsgForKey:(NSString *)key
{
	[self.noResultsView hide:TRUE];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud == self.loadingView) {
		[self.loadingView removeFromSuperview];
		self.loadingView = nil;
	} else if (hud == self.noResultsView) {
		[self.noResultsView removeFromSuperview];
		self.noResultsView = nil;
	}
}

#pragma mark -
#pragma mark Network Availability

- (BOOL)isNetworkReachable
{
	return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != kNotReachable);	
}

#pragma mark -
#pragma mark Core Location

- (void)locationDidFix
{
	
}

- (void)locationDidStop
{
	
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Rotation Support

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	noResultsView.delegate = nil;
	[noResultsView release];
	loadingView.delegate = nil;
	[loadingView release];
	
    [super dealloc];
}

@end
