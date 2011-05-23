#import "TagsViewController.h"

@interface TagsViewController ()

@end


@implementation TagsViewController

@synthesize tagsLabel;

#pragma mark -
#pragma mark Initialisation

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Setup

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tagsLabel.backgroundColor = [UIColor clearColor];
    self.tagsLabel.promptText = @"Tags:";
    self.tagsLabel.delegate = self;
}

- (void) viewDidUnload
{
    self.tagsLabel = nil;
    
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Content reloading

#pragma mark -
#pragma mark TokenDelegate

- (void)tokenField:(TITokenField *)tokenField tokenTouched:(TIToken *)token
{
    if (self.editing ) {
        [self.tagsLabel becomeFirstResponder];
    } else {
        // token.title
    }
}

- (void)tokenFieldDidBeginEditing:(TITokenField *)tokenField
{
    [self setEditing:TRUE animated:TRUE];
}

- (void)tokenFieldDidEndEditing:(TITokenField *)tokenField
{
    // [[self.tagsLabel.tokensArray valueForKey:@"title"] componentsJoinedByString:@", "]
}

#pragma mark -
#pragma mark Actions


#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[tagsLabel release];
	
	[super dealloc];
}

@end
