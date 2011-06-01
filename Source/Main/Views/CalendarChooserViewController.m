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
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(closeButtonTouched)] autorelease];
}
    
- (void)setupDataSource
{
	[super setupDataSource];
	
	EKEventStore *store = [[[EKEventStore alloc] init] autorelease];
	
	self.calendarChooserDataSource = [[[CalendarChooserDataSource alloc] init] autorelease];
    [self.calendarChooserDataSource.content addObjectsFromArray:store.calendars];
    self.calendarChooserDataSource.selectedCalendar = [store defaultCalendarForNewEvents];
	self.tableView.dataSource = self.calendarChooserDataSource;
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	EKCalendar *calendar = [self.calendarChooserDataSource calendarForIndexPath:indexPath];
    
    self.calendarChooserDataSource.selectedCalendar = calendar;
	
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
