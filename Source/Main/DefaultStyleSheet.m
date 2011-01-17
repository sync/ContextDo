#import "DefaultStyleSheet.h"
#import "CustomNavigationBar.h"

@implementation DefaultStyleSheet

SYNTHESIZE_SINGLETON_FOR_CLASS(DefaultStyleSheet)

- (UIImage *)navBarBackgroundImage
{
	return [UIImage imageNamed:@"titlebar.png"];
}

- (UIBarButtonItem *)backItemWithTitle:(NSString *)title target:(id)target selector:(SEL)action
{
	UIButton *backButton = [CustomNavigationBar customBackButtonForBackgroundImage:[UIImage imageNamed:@"btn_backarrow_off.png"]
																  highlightedImage:[UIImage imageNamed:@"btn_backarrow_touch.png"] 
																	  leftCapWidth:16.0
																			 title:title
																			  font:[UIFont boldSystemFontOfSize:14.0]];
	
	backButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
	[backButton setTitleColor:[UIColor colorWithHexString:@"7e7e83"] forState:UIControlStateNormal];
	[backButton setTitleColor:[UIColor colorWithHexString:@"7e7e83"] forState:UIControlStateHighlighted];
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

@end
