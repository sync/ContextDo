#import "BaseTableViewDataSource.h"


@implementation BaseTableViewDataSource

@synthesize content;

#pragma mark -
#pragma mark Content

- (NSMutableArray *)content
{
	if (!content) {
		content = [[NSMutableArray alloc]init];
	}
	return content;
}

#pragma mark -
#pragma mark Reset Content

- (void)resetContent
{
	// refresh content
	[self.content removeAllObjects];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > 0
		&& [[self.content objectAtIndex:0]respondsToSelector:@selector(objectAtIndex:)]) {
		return self.content.count;
	}
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	// Check if content first elemetn return array or not
	// If yes, tableview has more than one section
	if (self.content && self.content.count > section
		&& [[self.content objectAtIndex:section]respondsToSelector:@selector(objectAtIndex:)]) {
		return [[self.content objectAtIndex:section]count];
	}
	return self.content.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define MyCellIdentifier @"MyCellIdentifier"
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyCellIdentifier] autorelease];
    }
	
	return cell;
}

#pragma mark -
#pragma mark Table view methods helper

- (id)objectForIndexPath:(NSIndexPath *)indexPath;
{
	// Hack to see if array has got multiple sections or not
	NSArray *firstLevel = nil;
	if (self.content && self.content.count > indexPath.section
		&& [[self.content objectAtIndex:indexPath.section]respondsToSelector:@selector(objectAtIndex:)] 
		&& self.content.count>indexPath.section) {
		firstLevel = [self.content objectAtIndex:indexPath.section];
	} else {
		firstLevel = self.content;
	}
	// if nothing return nil
	return (firstLevel.count>indexPath.row)?[firstLevel objectAtIndex:indexPath.row]:nil; 
}

- (void)dealloc
{
	[content release];
	
	[super dealloc];
}

@end
