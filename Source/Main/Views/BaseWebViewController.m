#import "BaseWebViewController.h"

@interface BaseWebViewController (private)

- (void)doneButtonTouched;
- (void)backButtonTouched;
- (void)forwardButtonTouched;
- (void)actionButtonTouched;
- (void)loadRequest;

@end


@implementation BaseWebViewController

@synthesize webView, request;

#pragma mark -
#pragma mark Setup

- (void)viewWillDisappear:(BOOL)animated
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.webView.delegate = self;
	
	[self loadRequest];
}

- (void)setupNavigationBar
{
	self.navigationController.navigationBar.hidden = TRUE;
}

- (void)setupToolbar
{	
	self.navigationController.toolbar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.toolbar.translucent = FALSE;
	[self.navigationController setToolbarHidden:FALSE animated:FALSE];
	
	UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil]autorelease];
	
	UIBarButtonItem *fixItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			  target:nil
																			  action:nil]autorelease];
	fixItem.width = 30.0;
	
	UIBarButtonItem *backItem = [[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"left-arrow.png"]
																 style:UIBarButtonItemStylePlain 
																target:self 
																action:@selector(backButtonTouched)]autorelease];
	if ([self.webView canGoBack]) {
		backItem.enabled = TRUE;
	} else {
		backItem.enabled = FALSE;
	}
	
	UIBarButtonItem *forwardItem = [[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"right-arrow.png"]
																 style:UIBarButtonItemStylePlain 
																target:self 
																action:@selector(forwardButtonTouched)]autorelease];
	if ([self.webView canGoForward]) {
		forwardItem.enabled = TRUE;
	} else {
		forwardItem.enabled = FALSE;
	}
	
	UIBarButtonItem *actionItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			  target:self 
																			  action:@selector(actionButtonTouched)]autorelease];
	
	UIBarButtonItem *doneItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self 
																			  action:@selector(doneButtonTouched)]autorelease];
	
	NSArray *items = [NSArray arrayWithObjects:
					  flexItem,
					  backItem,
					  fixItem,
					  actionItem,
					  fixItem,
					  forwardItem,
					  fixItem,
					  doneItem,
					  nil];
	[self setToolbarItems:items animated:FALSE];
}

#pragma mark -
#pragma mark Request

- (void)loadRequest
{
	if (self.request) {
		[self.webView loadRequest:self.request];
	}
}

- (void)setRequest:(NSURLRequest *)aRequest
{
	if (![request isEqual:aRequest]) {
		[request release];
		request = [aRequest retain];
	}
}

#pragma mark -
#pragma mark WebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// Show the netowrk activity indicator while operation is doing something
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self setupToolbar];
	
	// Show the netowrk activity indicator while operation is doing something
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self setupToolbar];
	
	// Show the netowrk activity indicator while operation is doing something
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

#pragma mark -
#pragma mark Action

- (void)doneButtonTouched
{
	[self dismissModalViewControllerAnimated:TRUE];
}

- (void)backButtonTouched
{
	if ([self.webView canGoBack]) {
		[self.webView goBack];
	}
}

- (void)forwardButtonTouched
{
	if ([self.webView canGoForward]) {
		[self.webView goForward];
	}
}

- (void)actionButtonTouched
{
	UIActionSheet *alertSheet =
	[[UIActionSheet alloc] initWithTitle:nil
								delegate:self 
					   cancelButtonTitle:@"Cancel" 
				  destructiveButtonTitle:nil
					   otherButtonTitles:@"Open in Safari", nil];
	
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[alertSheet showInView:self.view];
	[alertSheet release];
}

#pragma mark -
#pragma mark actionSheet

// change the navigation bar style, also make the status bar match with it
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [modalView buttonTitleAtIndex:buttonIndex];
	
	if ([title isEqualToString:@"Open in Safari"]) {
		if (![[UIApplication sharedApplication]openURL:self.webView.request.URL]) {
			[[UIApplication sharedApplication]openURL:self.request.URL];
		}
	}
}

#pragma mark -
#pragma mark Memory

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.webView = nil;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[request release];
	[webView release];
	
    [super dealloc];
}


@end
