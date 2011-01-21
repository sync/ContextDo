#import "TaskLocationViewController.h"


@implementation TaskLocationViewController

@synthesize mapView;

#pragma mark -
#pragma mark Initialisation

- (void)viewWillAppear:(BOOL)animated
{
	// nothing
}

- (void)viewDidLoad 
{
	self.title = @"Edit Location";
	
    [super viewDidLoad];
	
	CALayer *layer = [self.mapView layer];
	layer.masksToBounds = YES;
	[layer setCornerRadius:5.0];
	[layer setBorderWidth:0.5];
	[layer setBorderColor:[[UIColor colorWithHexString:@"bbb"] CGColor]];
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.mapView = nil;
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:@"Back"
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
	
	self.title = @"Edit Location";
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
	
	self.navigationItem.rightBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet]navBarButtonItemWithText:@"Clear"
																										   target:self
																										 selector:@selector(clearTouched)];
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	
	self.taskEditDataSource = [[[TaskLocationDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.taskEditDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
	self.taskEditDataSource.tempTask = (self.task) ? self.task : [[[Task alloc]init]autorelease];
	self.tableView.sectionFooterHeight = 0.0;
	self.tableView.sectionHeaderHeight = 12.0;
	
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:PlaceNamePlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:StreetPlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:SuburbPlaceHolder]];
	[self.tableView reloadData];
	//[self startEditing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self endEditing];
}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
	if (self.keyboardShown) {
		return;
	}
	
	self.keyboardShown = TRUE;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	if (!self.keyboardShown) {
		return;
	}
	
	self.keyboardShown = FALSE;
}

#pragma mark -
#pragma mark Actions

- (void)clearTouched
{
	// TODO
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[mapView release];
	
	[super dealloc];
}

@end
