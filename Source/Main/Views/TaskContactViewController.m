#import "TaskContactViewController.h"


@implementation TaskContactViewController

#pragma mark -
#pragma mark Initialisation

- (void)viewWillAppear:(BOOL)animated
{
	// nothing
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.title = @"Edit Contact";
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:@"Back"
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
	
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	
	self.taskEditDataSource = [[[TaskContactDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.taskEditDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
	self.taskEditDataSource.tempTask = self.task;;
	self.tableView.sectionFooterHeight = 0.0;
	self.tableView.sectionHeaderHeight = 12.0;
	
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:ContactNamePlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:ContactDetailPlaceHolder]];
	[self.tableView reloadData];
	[self startEditing];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
