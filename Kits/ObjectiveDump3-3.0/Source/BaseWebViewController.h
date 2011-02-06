#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BaseWebViewController : BaseViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) NSURLRequest *request;

@end
