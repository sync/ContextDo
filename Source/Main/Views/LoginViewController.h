#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LoginViewController : BaseViewController <UITextFieldDelegate> {

}

@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

- (void)startEditing;
- (void)endEditing;
- (BOOL)shouldReturn;
- (void)goNext;
- (void)shouldReloadContent:(NSNotification *)notification;

- (IBAction)shouldRegister;
- (IBAction)shouldResetPassword;

@end