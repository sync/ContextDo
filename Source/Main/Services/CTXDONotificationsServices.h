#import <UIKit/UIKit.h>


@interface CTXDONotificationsServices : NSObject {

}

+ (CTXDONotificationsServices *)sharedCTXDONotificationsServices;

- (void)parseNotification:(UILocalNotification *)notification ;
- (void)refreshTasksForLocalNotification;

@end
