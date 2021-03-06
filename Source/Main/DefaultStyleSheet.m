#import "DefaultStyleSheet.h"
#import "UINavigationController+Custom.h"


@implementation DefaultStyleSheet

SYNTHESIZE_SINGLETON_FOR_CLASS(DefaultStyleSheet)

- (UIImage *)navBarBackgroundImage
{
	return [UIImage imageNamed:@"titlebar.png"];
}

- (UIBarButtonItem *)backItemWithText:(NSString *)text target:(id)target selector:(SEL)action
{
	UIButton *backButton = [CustomNavigationBar customBackButtonForBackgroundImage:[UIImage imageNamed:@"btn_backarrow_off.png"]
																  highlightedImage:[UIImage imageNamed:@"btn_backarrow_touch.png"] 
																	  leftCapWidth:16.0
																			 title:text
																			  font:[UIFont boldSystemFontOfSize:14.0]];
	
	backButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	backButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
	[backButton setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateNormal];
	[backButton setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateHighlighted];
	
	[backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	return [[[UIBarButtonItem alloc]initWithCustomView:backButton]autorelease];
}

- (UILabel *)titleViewWithText:(NSString *)text
{
	UILabel *label = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
	label.font = [UIFont boldSystemFontOfSize:16.0];
	label.shadowOffset = CGSizeMake(0,-1);
	label.textColor = [UIColor colorWithHexString:@"FFF"];
	label.shadowColor = [UIColor colorWithHexString:@"00000040"];
	label.textAlignment = UITextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	
	label.text = text;
	[label sizeToFit];
	
	return label;
}

#define LeftRightDiffNavBarButton 8.0
#define NavBarButtonMinWidth 65.0

- (UIBarButtonItem *)navBarButtonItemWithText:(NSString *)text target:(id)target selector:(SEL)action
{
	UIButton *button = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	UIImage *image = [UIImage imageNamed:@"btn-gry_tbar_off.png"];
	image = [image stretchableImageWithLeftCapWidth:(image.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[button setBackgroundImage:image forState:UIControlStateNormal];
	
	UIImage *highlightedImage = [UIImage imageNamed:@"btn-gry_tbar_touch.png"];
	highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:(highlightedImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	
	button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	[button setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateHighlighted];
	
	CGSize textSize = [text sizeWithFont:button.titleLabel.font];
	CGFloat buttonWidth = textSize.width + 2 * LeftRightDiffNavBarButton;
	button.frame = CGRectMake(button.frame.origin.x, 
							  button.frame.origin.y, 
							  (buttonWidth > NavBarButtonMinWidth) ? buttonWidth : NavBarButtonMinWidth, 
							  image.size.height);
	[button setTitle:text forState:UIControlStateNormal];
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *item = [[[UIBarButtonItem alloc]initWithCustomView:button]autorelease];
	return item;
}

- (UIBarButtonItem *)doneNavBarButtonItemWithText:(NSString *)text target:(id)target selector:(SEL)action
{
	UIButton *button = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	UIImage *image = [UIImage imageNamed:@"btn-blue_tbar_off.png"];
	image = [image stretchableImageWithLeftCapWidth:(image.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[button setBackgroundImage:image forState:UIControlStateNormal];
	
	UIImage *highlightedImage = [UIImage imageNamed:@"btn-blue_tbar_touch.png"];
	highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:(highlightedImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	
	button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	[button setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateHighlighted];
	
	CGSize textSize = [text sizeWithFont:button.titleLabel.font];
	CGFloat buttonWidth = 
	textSize.width + 2 * LeftRightDiffNavBarButton;
	button.frame = CGRectMake(button.frame.origin.x, 
							  button.frame.origin.y, 
							  (buttonWidth > NavBarButtonMinWidth) ? buttonWidth : NavBarButtonMinWidth, 
							  image.size.height);
	[button setTitle:text forState:UIControlStateNormal];
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *item = [[[UIBarButtonItem alloc]initWithCustomView:button]autorelease];
	return item;
}

- (UIBarButtonItem *)editBarButtonItemEditing:(BOOL)editing target:(id)target selector:(SEL)action
{
	UIBarButtonItem *item = nil;
	if (!editing) {
		item = [[DefaultStyleSheet sharedDefaultStyleSheet] navBarButtonItemWithText:@"Edit"
																			  target:target
																			selector:action];
	} else {
		item = [[DefaultStyleSheet sharedDefaultStyleSheet] doneNavBarButtonItemWithText:@"Done"
																				  target:target
																				selector:action];
	}
	
	return item;
}

- (UIImage *)toolbarBackgroundImage
{
	return [UIImage imageNamed:@"taskbar.png"];
}

- (UIImage *)toolbarShadowImage
{
	return [UIImage imageNamed:@"taskbar_shadow.png"];
}

- (UIBarButtonItem *)buttonItemWithImageNamed:(NSString *)imageNamed highlightedImageNamed:(NSString *)highlightedImageNamed target:(id)target selector:(SEL)action
{
	UIButton *button = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
	
	[button setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
	[button setImage:[UIImage imageNamed:highlightedImageNamed] forState:UIControlStateHighlighted];
	
	button.frame = CGRectMake(button.frame.origin.x, 
							  button.frame.origin.y, 
							  [UIImage imageNamed:imageNamed].size.width, 
							  [UIImage imageNamed:imageNamed].size.height);
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *item = [[[UIBarButtonItem alloc]initWithCustomView:button]autorelease];
	return item;
}

- (UIColor *)darkBackgroundTexture
{
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgtexture.png"]];
}

- (UIColor *)backgroundTexture
{
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_addtask.png"]];
}

- (UIButton *)inputTextFieldButtonWithText:(NSString *)text target:(id)target selector:(SEL)action
{		
	UIButton *button = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	UIImage *image = [UIImage imageNamed:@"btn_inputfield_off.png"];
	image = [image stretchableImageWithLeftCapWidth:(image.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[button setBackgroundImage:image forState:UIControlStateNormal];
	
	UIImage *highlightedImage = [UIImage imageNamed:@"btn_inputfield_touch.png"];
	highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:(highlightedImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	
	button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	[button setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateHighlighted];
	
	CGSize textSize = [text sizeWithFont:button.titleLabel.font];
	CGFloat buttonWidth = textSize.width + 2 * LeftRightDiffNavBarButton;
	button.frame = CGRectMake(button.frame.origin.x, 
							  button.frame.origin.y, 
							  buttonWidth, 
							  image.size.height);
	[button setTitle:text forState:UIControlStateNormal];
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

- (UIColor *)blackedOutColor
{
	return [UIColor colorWithHexString:@"00000075"];
}

- (UIColor *)taskDarkGrayColor
{
	return [UIColor colorWithHexString:@"7d7d81"];
}

- (CustomNavigationController *)customNavigationControllerWithRoot:(UIViewController *)controller
{
	CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
											  forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarBackgroundImage
										forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setShadowImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarShadowImage
									forBarStyle:UIBarStyleBlackOpaque];
	
	return navController;
}

@end
