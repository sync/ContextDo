#import "CalendarChooserViewController.h"


@implementation CalendarChooserViewController

@synthesize calendarChooserDataSource;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{	
    [super viewDidLoad];
	
	self.title = @"Choose Calendar";
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
    [super setupNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] navBarButtonItemWithText:@"Close"
                                                                                                           target:self
                                                                                                         selector:@selector(closeButtonTouched)];
}
    
- (void)setupDataSource
{
	[super setupDataSource];
	
	NSArray *choicesList = [NSArray arrayWithObjects:@"MobileMe", @"Gmail", @"QUT", nil];
	
	self.calendarChooserDataSource = [[[CalendarChooserDataSource alloc]initWitChoicesList:choicesList]autorelease];
    self.calendarChooserDataSource.selectedCalendarName = @"QUT";
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTexture;
	self.tableView.dataSource = self.calendarChooserDataSource;
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *choice  = [self.calendarChooserDataSource choiceForIndexPath:indexPath];
    self.calendarChooserDataSource.selectedCalendarName = choice;
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    [self.tableView reloadData];
}

- (void)closeButtonTouched
{
	[self dismissModalViewControllerAnimated:TRUE];
}


- (void)dealloc
{
    [calendarChooserDataSource release];
    
    [super dealloc];
}

@end
