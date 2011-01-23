#import "TaskAnnotation.h"


@implementation TaskAnnotation

@synthesize task, coordinate, title, subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate
{
	if ([self init]) {
		self.coordinate = aCoordinate;
	}
	return self;
}

- (void)dealloc
{
	[subtitle release];
	[title release];
	[task release];
	
	[super dealloc];
}

@end
