#import "TasksScrollContainerViewController.h"
#import "NSString+Additions.h"
#import "TasksContainerViewController.h"
#import "CalendarChooserViewController.h"

static CGFloat const kSentDateFontSize = 13.0f;
static CGFloat const kMessageFontSize   = 16.0f;
static CGFloat const kMessageTextWidth  = 180.0f;
static CGFloat const kContentHeightMax  = 84.0f;
static CGFloat const kChatBarHeight1    = 40.0f;
static CGFloat const kChatBarHeight4    = 94.0f;

@interface TasksScrollContainerViewController ()

- (void)resetCreateButton;
- (void)enableCreateButton;
- (void)disableCreateButton;
- (void)resetCreateButton;
- (void)slideFrameUp;
- (void)slideFrameDown;
- (void)slideFrame:(BOOL)up;
- (void)dismissKeyboard;
- (void)updateTitle;

@end

@implementation TasksScrollContainerViewController

@synthesize scrollView, currentPage, chatBar, chatInput, previousContentHeight, createButton;
@synthesize searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentPage = 0;
    
#define LeftRightDiff 12.0
#define PageWidth 255.0
#define PagesDiff 24.0
#define PageHeight 357.0
#define TopDiff 0.0
#define NavDiff 44.0
    
    self.scrollView.contentSize = CGSizeMake(2 * LeftRightDiff + 3 * PageWidth + 2 * PagesDiff, PageHeight);
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.clipsToBounds = NO;
     
    TasksContainerViewController * controller1 = [[[TasksContainerViewController alloc] initWithNibName:@"TasksContainerView" bundle:nil]autorelease];
    controller1.view.transform = CGAffineTransformIdentity;
    controller1.view.transform = CGAffineTransformMakeScale(0.8, 0.8);
    controller1.view.frame = CGRectMake(LeftRightDiff, TopDiff, PageWidth, PageHeight + NavDiff);
    controller1.view.backgroundColor = [UIColor redColor];
    CALayer *layer1 = [controller1.view layer];
	layer1.masksToBounds = YES;
	[layer1 setBorderWidth:1.0];
	[layer1 setBorderColor:[[UIColor blackColor] CGColor]];
    [self.scrollView addSubview:controller1.view];
    [controller1 showCalendar];
    
    TasksContainerViewController * controller2 = [[[TasksContainerViewController alloc] initWithNibName:@"TasksContainerView" bundle:nil]autorelease];
    controller2.view.frame = CGRectMake(controller1.view.frame.origin.x + controller1.view.frame.size.width + PagesDiff, TopDiff, PageWidth, PageHeight + NavDiff);
    controller2.view.backgroundColor = [UIColor greenColor];
    CALayer *layer2 = [controller2.view layer];
	layer2.masksToBounds = YES;
	[layer2 setBorderWidth:1.0];
	[layer2 setBorderColor:[[UIColor blackColor] CGColor]];
    [self.scrollView addSubview:controller2.view];
    [controller2 showList];
    
    TasksContainerViewController * controller3 = [[[TasksContainerViewController alloc] initWithNibName:@"TasksContainerView" bundle:nil]autorelease];
    controller3.view.frame = CGRectMake(controller2.view.frame.origin.x + controller2.view.frame.size.width + PagesDiff, TopDiff, PageWidth, PageHeight + NavDiff);
    controller3.view.backgroundColor = [UIColor yellowColor];
    CALayer *layer3 = [controller3.view layer];
	layer3.masksToBounds = YES;
	[layer3 setBorderWidth:1.0];
	[layer3 setBorderColor:[[UIColor blackColor] CGColor]];
    [self.scrollView addSubview:controller3.view];
    [controller3 showMap];
    
    // chat
    // background
    chatBar = [[UIImageView alloc] initWithFrame:
               CGRectMake(0.0f, [self view].frame.size.height-kChatBarHeight1,
                          [self view].frame.size.width, kChatBarHeight1)];
    chatBar.clearsContextBeforeDrawing = NO;
    chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth;
    chatBar.image = [[UIImage imageNamed:@"ChatBar.png"]
                     stretchableImageWithLeftCapWidth:18 topCapHeight:20];
    chatBar.userInteractionEnabled = YES;
    [self.view addSubview:chatBar];
    
    // text input
    chatInput = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 9.0f, 234.0f, 22.0f)];
    chatInput.contentSize = CGSizeMake(234.0f, 22.0f);
    chatInput.delegate = self;
    chatInput.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    chatInput.scrollEnabled = NO; // not initially
    chatInput.scrollIndicatorInsets = UIEdgeInsetsMake(5.0f, 0.0f, 8.0f, -2.0f);
    chatInput.clearsContextBeforeDrawing = NO;
    chatInput.font = [UIFont systemFontOfSize:kMessageFontSize];
    chatInput.dataDetectorTypes = UIDataDetectorTypeAll;
    chatInput.backgroundColor = [UIColor clearColor];
    previousContentHeight = chatInput.contentSize.height;
    [chatBar addSubview:chatInput];
    
    // action button
    createButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    createButton.clearsContextBeforeDrawing = NO;
    createButton.frame = CGRectMake(chatBar.frame.size.width - 70.0f, 6.0f, 64.0f, 26.0f);
    createButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | // multi-line input
    UIViewAutoresizingFlexibleLeftMargin;                       // landscape
    UIImage *createButtonBackground = [UIImage imageNamed:@"CreateButton.png"];
    [createButton setBackgroundImage:createButtonBackground forState:UIControlStateNormal];
    [createButton setBackgroundImage:createButtonBackground forState:UIControlStateDisabled];
    createButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    createButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
    UIColor *shadowColor = [[UIColor alloc] initWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [createButton setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    [shadowColor release];
    [createButton addTarget:self action:@selector(createEvent)
         forControlEvents:UIControlEventTouchUpInside];
    [self resetCreateButton]; // disable initially
    [chatBar addSubview:createButton];
    
    // Listen for keyboard.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
//    //disables the built-in pan gesture
//    for (UIGestureRecognizer *gesture in scrollView.gestureRecognizers){
//        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]){
//            UIPanGestureRecognizer * panGesture = (UIPanGestureRecognizer *)gesture;
//            panGesture.minimumNumberOfTouches = 3;
//            panGesture.maximumNumberOfTouches = 3;
//        }
//    }
    
//    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self 
//                                                                                  action:@selector(pangGesture:)];
//    [self.view addGestureRecognizer:panGesture];
//    [panGesture release];
    
//    UISwipeGestureRecognizer * leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                                        action:@selector(leftSwipe)];
//    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    leftSwipeGesture.delegate = self;
//    [self.view addGestureRecognizer:leftSwipeGesture];
//    [leftSwipeGesture release];
//    
//    UISwipeGestureRecognizer * rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                                            action:@selector(rightSwipe)];
//    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
//    rightSwipeGesture.delegate = self;
//    [self.view addGestureRecognizer:rightSwipeGesture];
//    [rightSwipeGesture release];
    
    // Gesture dismiss
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(dismissKeyboard)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.scrollView = nil;
    self.chatBar = nil;
    
    [super viewDidUnload];
}

- (void) setupNavigationBar
{
    [super setupNavigationBar];
    
    UIButton *calendarButton = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
	UIImage *calendarImage = [UIImage imageNamed:@"calendar.png"];
	[calendarButton setImage:calendarImage forState:UIControlStateNormal];
	calendarButton.frame = CGRectMake(calendarButton.frame.origin.x, 
							  calendarButton.frame.origin.y, 
							  calendarImage.size.width + 10.0, 
							  calendarImage.size.height);
	[calendarButton addTarget:self action:@selector(calendarTouched) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *calendarItem = [[[UIBarButtonItem alloc]initWithCustomView:calendarButton]autorelease];
    self.navigationItem.leftBarButtonItem = calendarItem;
    
    UIButton *searchButton = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
	UIImage *searchImage = [UIImage imageNamed:@"06-magnify.png"];
	[searchButton setImage:searchImage forState:UIControlStateNormal];
	searchButton.frame = CGRectMake(searchButton.frame.origin.x, 
                                 searchButton.frame.origin.y, 
                                 searchImage.size.width + 10.0, 
                                 searchImage.size.height);
	[searchButton addTarget:self action:@selector(searchTouched) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *searchItem = [[[UIBarButtonItem alloc]initWithCustomView:searchButton]autorelease];
    self.navigationItem.rightBarButtonItem = searchItem;
    
    [self updateTitle];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.createButton ||
        touch.view == self.chatBar ||
        touch.view == self.chatInput) {
        return NO;
    }
    
    return YES;
}

- (void)leftSwipe
{
    [self scrollToRowAtIndex:self.currentPage - 1 animated:YES];
}

- (void)rightSwipe
{
     [self scrollToRowAtIndex:self.currentPage + 1 animated:YES];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (self.currentPage != self.pageIndex) {
        self.currentPage = self.pageIndex;
        NSLog(@"did scroll to page: %d", self.pageIndex);
        [self updateTitle];
    }
}

- (NSInteger)pageIndex
{
	// make sure it snaps to grid
	CGFloat itemWidth = PageWidth + PagesDiff;
	CGFloat itemLocation = (self.scrollView.contentOffset.x / itemWidth);
	
	NSInteger itemIndex =  round(itemLocation);
	
	NSInteger count = 3;
	
	if (itemIndex < 0 && itemIndex < count) {
		itemIndex = 0;
	}
	
	if (itemIndex > count - 1) {
		itemIndex = count - 1;
	}
    
    return itemIndex;
}

#pragma mark UITextViewDelegate

#define VIEW_WIDTH    self.view.frame.size.width
#define VIEW_HEIGHT    self.view.frame.size.height

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat contentHeight = textView.contentSize.height - kMessageFontSize + 2.0f;
    NSString *rightTrimmedText = @"";
    
    //    NSLog(@"contentOffset: (%f, %f)", textView.contentOffset.x, textView.contentOffset.y);
    //    NSLog(@"contentInset: %f, %f, %f, %f", textView.contentInset.top, textView.contentInset.right,
    //          textView.contentInset.bottom, textView.contentInset.left);
    //    NSLog(@"contentSize.height: %f", contentHeight);
    
    if ([textView hasText]) {
        rightTrimmedText = [textView.text
                            stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
        
        //        if (textView.text.length > 1024) { // truncate text to 1024 chars
        //            textView.text = [textView.text substringToIndex:1024];
        //        }
        
        // Resize textView to contentHeight
        if (contentHeight != previousContentHeight) {
            if (contentHeight <= kContentHeightMax) { // limit chatInputHeight <= 4 lines
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.1f];
                CGFloat chatBarHeight = contentHeight + 18.0f;
                // comput y diff + add height from current
                CGRect chatBarFrame = self.chatBar.frame;
                chatBarFrame.origin.y -= chatBarHeight - chatBarFrame.size.height;
                chatBarFrame.size.height = chatBarHeight;
                self.chatBar.frame = CGRectIntegral(chatBarFrame);
                [UIView commitAnimations];
                if (previousContentHeight > kContentHeightMax) {
                    textView.scrollEnabled = NO;
                }
                textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
            } else if (previousContentHeight <= kContentHeightMax) { // grow
                textView.scrollEnabled = YES;
                textView.contentOffset = CGPointMake(0.0f, contentHeight-68.0f); // shift to bottom
                if (previousContentHeight < kContentHeightMax) {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.1f];
                    CGFloat chatBarHeight = kChatBarHeight4;
                    // comput y diff + add height from current
                    CGRect chatBarFrame = self.chatBar.frame;
                    chatBarFrame.origin.y -= chatBarHeight - chatBarFrame.size.height;
                    chatBarFrame.size.height = chatBarHeight;
                    self.chatBar.frame = CGRectIntegral(chatBarFrame);
                    [UIView commitAnimations];
                }
            }
        }
    } else { // textView is empty
        if (previousContentHeight > 22.0f) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1f];
            CGFloat chatBarHeight = kChatBarHeight1;
            // comput y diff + add height from current
            CGRect chatBarFrame = self.chatBar.frame;
            chatBarFrame.origin.y -= chatBarHeight - chatBarFrame.size.height;
            chatBarFrame.size.height = chatBarHeight;
            self.chatBar.frame = CGRectIntegral(chatBarFrame);
            [UIView commitAnimations];
            if (previousContentHeight > kContentHeightMax) {
                textView.scrollEnabled = NO;
            }
        }
        textView.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
    }
    
    // Enable sendButton if chatInput has non-blank text, disable otherwise.
    if (rightTrimmedText.length > 0) {
        [self enableCreateButton];
    } else {
        [self disableCreateButton];
    }
    
    previousContentHeight = contentHeight;
}

// Fix a scrolling quirk.
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
    return YES;
}

#pragma mark - Keyboard

// Prepare to resize for keyboard.
- (void)keyboardWillShow:(NSNotification *)notification 
{
    //    NSDictionary *userInfo = [notification userInfo];
    //    CGRect bounds;
    //    [(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
    
    //    // Resize text view
    //    CGRect aFrame = chatInput.frame;
    //    aFrame.size.height -= bounds.size.height;
    //    chatInput.frame = aFrame;
    
    [self slideFrameUp];
    // These methods can do better.
    // They should check for version of iPhone OS.
    // And use appropriate methods to determine:
    //   animation movement, speed, duration, etc.
}

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification 
{
    //    NSDictionary *userInfo = [notification userInfo];
    //    CGRect bounds;
    //    [(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
    
    [self slideFrameDown];
}

- (void)slideFrameUp 
{
    [self slideFrame:YES];
}

- (void)slideFrameDown 
{
    [self slideFrame:NO];
}

// Shorten height of UIView when keyboard pops up
// TODO: Test on different SDK versions; make more flexible if desired.
- (void)slideFrame:(BOOL)up 
{
    if (![chatInput isFirstResponder]) {
        return;
    }
    
    CGFloat movementDistance;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    movementDistance = orientation == UIInterfaceOrientationPortrait ||
    orientation == UIInterfaceOrientationPortraitUpsideDown ? 216.0f : 162.0f;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    CGRect chatBarFrame = self.chatBar.frame;
    chatBarFrame.origin.y += up ? -movementDistance : movementDistance;
    self.chatBar.frame = chatBarFrame;
    [UIView commitAnimations];
    
    chatInput.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
    chatInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
}

#pragma mark - Actions

- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
	NSInteger itemIndex = index;
	
	NSInteger count = 3.0;
	
	if (itemIndex < 0 && itemIndex < count) {
		itemIndex = 0;
	}
	
	if (itemIndex > count - 1) {
		itemIndex = count - 1;
	}
	
	if (itemIndex >= 0) {
		// Remember which index we are targeting so we can ignore intermediates along the way
		[self.scrollView setContentOffset:CGPointMake(itemIndex * (PageWidth + PagesDiff), 0.0) animated:animated];
	}
}
                                           
- (void)dismissKeyboard
{
    [chatInput resignFirstResponder];
}

- (void)createEvent
{
    [self dismissKeyboard];
    
    UIActionSheet * actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Would you like to add more information?" 
                                                               delegate:self
                                                      cancelButtonTitle:@"No" 
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Yes", nil]autorelease];
    [actionSheet showInView:self.view];
}

- (void)resetCreateButton
{
    createButton.enabled = NO;
    createButton.titleLabel.alpha = 0.5f; // Sam S. says 0.4f
}

- (void)enableCreateButton 
{
    if (createButton.enabled == NO) {
        createButton.enabled = YES;
        createButton.titleLabel.alpha = 1.0f;
    }
}

- (void)disableCreateButton 
{
    if (createButton.enabled == YES) {
        [self resetCreateButton];
    }
}

- (void)calendarTouched
{
    CalendarChooserViewController * controller = [[[CalendarChooserViewController alloc] initWithNibName:@"CalendarChooserView" bundle:nil]autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	[self.navigationController presentModalViewController:navController animated:TRUE];
}

- (BOOL)isShowingSearchBar
{
    return (self.searchBar.frame.origin.y == 0);
}

- (void)searchTouched
{
    if (self.isShowingSearchBar) {
        [self.searchBar resignFirstResponder];
    } else {
        [self.searchBar becomeFirstResponder];
    }
    
    CGFloat newY = (self.isShowingSearchBar) ? -44.0 : 0.0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = self.searchBar.frame;
    frame.origin.y = newY;
    self.searchBar.frame = frame;
    
    [UIView commitAnimations];
}

- (void)updateTitle
{
    NSString *title = nil;
    switch (self.currentPage) {
        case 0:
            title = @"Calendar";
            break;
        case 1:
            title = @"List";
            break;
        case 2:
            title = @"Map";
            break;
    }
    self.title = title;
}

#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EKEventStore *store = [[[EKEventStore alloc] init] autorelease];
    
    EKEvent * event = [EKEvent eventWithEventStore:store];
    [event setTitle:chatInput.text];
    
    chatInput.text = @"";
    [self textViewDidChange:chatInput];
    
    if (buttonIndex == 0) {
        // Yes
        NSLog(@"Yes");
        
        EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
        eventViewController.event = event;
        eventViewController.allowsEditing = YES; 
        UINavigationController *navigationController = nil;
        navigationController = [[UINavigationController alloc] initWithRootViewController:eventViewController]; 
        [eventViewController release];
        
         [self presentModalViewController:navigationController animated:YES];
        
//        EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
//        controller.eventStore = store;
//        controller.event = event;
//        controller.editViewDelegate = self; 
//        [self presentModalViewController: controller animated:YES]; 
//        [controller release];
        
    } else {
        // No
        NSLog(@"No");
    }
}

#pragma mark - EventKitDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Dealloc

- (void)dealloc
{
    [searchBar release];
    [createButton release];
    [chatInput release];
    [chatBar release];
    [scrollView release];
    
    [super dealloc];
}

@end
