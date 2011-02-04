#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "CTXDODarkTextField.h"

@interface ResetPasswordViewController :  BaseViewController <UITextFieldDelegate> {

}

@property (nonatomic, retain) IBOutlet CTXDODarkTextField *usernameTextField;

- (void)startEditing;
- (void)endEditing;
- (BOOL)shouldReturn;

- (IBAction)shouldResetPassword;

@end
