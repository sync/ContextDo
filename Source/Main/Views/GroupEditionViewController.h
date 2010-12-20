#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface GroupEditionViewController : BaseViewController <UITextFieldDelegate> {
	
}

@property (nonatomic, copy) NSString *interest;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) IBOutlet UITextField *interestLabel;

@property (nonatomic, assign) id delegate;

@end

@protocol ProfileEditionViewControllerDelegate <NSObject>

- (void)profileEditionViewController:(GroupEditionViewController *)controller doneEditingWithInterest:(NSString *)interest forIndexPath:(NSIndexPath *)indexPath;

@end

