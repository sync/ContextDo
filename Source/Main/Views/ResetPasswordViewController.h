#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface ResetPasswordViewController :  BaseViewController <UITextFieldDelegate> {

}

@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;

- (void)startEditing;
- (void)endEditing;
- (BOOL)shouldReturn;
- (void)shouldReloadContent:(NSNotification *)notification;

@end
