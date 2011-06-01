#import <Foundation/Foundation.h>
#import "BaseTableViewDataSource.h"

@interface CalendarChooserDataSource : BaseTableViewDataSource {
    
}

@property (nonatomic, retain) EKCalendar *selectedCalendar;

- (EKCalendar *)calendarForIndexPath:(NSIndexPath *)indexPath;

@end
