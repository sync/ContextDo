#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface GroupEditionViewController : BaseViewController <UITextFieldDelegate> {
	
}

@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) IBOutlet UITextField *groupTextField;

@end
