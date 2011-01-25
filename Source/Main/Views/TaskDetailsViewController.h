#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TaskDetailsView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface TaskDetailsViewController : BaseViewController <MFMailComposeViewControllerDelegate> {

}

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) IBOutlet TaskDetailsView *taskDetailsView;

- (IBAction)mailTouched;
- (IBAction)editTouched;
- (IBAction)deleteTouched;

- (void)refreshTask;

@property (nonatomic,  assign) UINavigationController *mainNavController;

@end
