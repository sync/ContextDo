#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CTXDODarkTextField.h"

@interface LoginViewController : BaseViewController <UITextFieldDelegate> {

}

@property (nonatomic, retain) IBOutlet CTXDODarkTextField *usernameTextField;
@property (nonatomic, retain) IBOutlet CTXDODarkTextField *passwordTextField;

- (void)startEditing;
- (void)endEditing;
- (BOOL)shouldReturn;
- (void)goNext;
- (void)shouldReloadContent:(NSNotification *)notification;

- (IBAction)shouldResetPassword;

@end