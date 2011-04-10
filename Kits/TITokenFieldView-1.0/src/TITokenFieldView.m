//
//  TITokenFieldView.m
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TITokenFieldView.h"

#define textEmpty @" " // Just a space
#define textHidden @"`" // This character isn't available on the iPhone (yet) so it's safe.

@interface TITokenField ()
- (void)setupCustomInitialisation;
@property (nonatomic, assign) UITextField *textField;
@property (nonatomic, readwrite, retain) NSMutableArray * tokensArray;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) UILabel *promptLabel;
@property (nonatomic) BOOL keyboardShown;
@end

#pragma mark -
#pragma mark TITokenField

@implementation TITokenField

@synthesize tokensArray, textField, delegate, numberOfLines;
@synthesize promptLabel, keyboardShown;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self){
		[self setupCustomInitialisation];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
    if (self) {
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	self.tokensArray = [NSMutableArray array];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.promptLabel = [[[UILabel alloc] initWithFrame:CGRectZero]autorelease];
    [self.promptLabel setFont:[UIFont systemFontOfSize:15]];
	[self.promptLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
    [self addSubview:self.promptLabel];
    
    self.textField = [[[UITextField alloc]initWithFrame:CGRectZero]autorelease];
    self.textField.delegate = self;
    [self.textField setBorderStyle:UITextBorderStyleNone];
    [self.textField setTextColor:[UIColor blackColor]];
    [self.textField setFont:[UIFont systemFontOfSize:14]];
    [self.textField setBackgroundColor:[UIColor whiteColor]];
    [self.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textField setTextAlignment:UITextAlignmentLeft];
    [self.textField setKeyboardType:UIKeyboardTypeDefault];
    [self.textField setReturnKeyType:UIReturnKeyDefault];
    [self.textField setClearsOnBeginEditing:NO];
    [self.textField setLeftViewMode:UITextFieldViewModeNever];
    [self addSubview:self.textField];
    
    self.keyboardShown = FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]autorelease];
	gestureRecognizer.delegate = self;
	[self addGestureRecognizer:gestureRecognizer];
    
    // We don't just set a leftside view
    // as it centers vertically on resize.
    // This is not something we want,
    // so instead, we add a subview.
    self.promptText = @"To:";
    
    self.text = textEmpty;
}

#pragma mark
#pragma mark - Text

- (NSString *)text
{
    return self.textField.text;
}

- (void)setText:(NSString *)aText
{
    self.textField.text = aText;
}

#pragma mark -
#pragma mark Prompt

- (NSString *)promptText
{
    return self.promptLabel.text;
}

- (void)setPromptText:(NSString *)aText {
    self.promptLabel.text = aText;
	[self layoutSubviews];
}

#pragma mark
#pragma mark - Token Handlers

- (void)addToken:(NSString *)title {
	if (!title || title.length == 0){
		return;
	}
    
    TIToken * token = [[[TIToken alloc] initWithTitle:title]autorelease];
    token.delegate = self;
    
    [self addSubview:token];
    [tokensArray addObject:token];
    
    self.text = textEmpty;
    [self layoutSubviews];
}

- (void)removeToken:(TIToken *)token {
    if (!token) {
        return;
    }
	[token removeFromSuperview];
	[tokensArray removeObject:token];
	
	self.text = textEmpty;
	[self layoutSubviews];
}

- (void)tokenGotFocus:(TIToken *)token {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlighted == TRUE"];
    NSArray *tokens = [tokensArray filteredArrayUsingPredicate:predicate];
	for (TIToken * tok in tokens){
		if (tok != token){
            tok.highlighted = NO;
		}
	}
    
    self.text = textHidden;
    [self layoutSubviews];
    
    if ([self.delegate respondsToSelector:@selector(tokenField:tokenTouched:)]){
		[self.delegate tokenField:self tokenTouched:token];
	}
}

#pragma mark -
#pragma mark Gesture

- (void)handleGesture:(UIGestureRecognizer *)aGestureRecognizer;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"highlighted == TRUE"];
    NSArray *tokens = [tokensArray filteredArrayUsingPredicate:predicate];
	for (TIToken * token in tokens){
        token.highlighted = NO;
	}
	
	if ([self.textField.text isEqualToString:textHidden]){
		self.text = textEmpty;
	}
    
    BOOL touched = FALSE;
	CGPoint currentTouchPosition = [aGestureRecognizer locationInView:self]; 
	for (TIToken *token in self.tokensArray) {
        if (CGRectContainsPoint(token.frame, currentTouchPosition)) {
            token.highlighted = YES;
            touched = TRUE;
            break;
        }
    }
    if (!touched) {
        [self becomeFirstResponder];
        [self layoutSubviews];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)processLeftoverText:(NSString *)text {
	if (![text isEqualToString:textEmpty] && ![text isEqualToString:textHidden] && 
		[[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0){
		
		NSString * title = nil;
		if ([[text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]){
			title = [text substringWithRange:NSMakeRange(1, [text length] - 1)];
		} else {
			title = [text substringWithRange:NSMakeRange(0, [text length] - 1)];
		}
		
		[self addToken:title];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)aTextField {
	if (![aTextField.text isEqualToString:textEmpty] && ![aTextField.text isEqualToString:textHidden] && ![aTextField.text isEqualToString:@""]){
		
		NSArray * titles = [NSArray arrayWithArray:self.tokensArray];
		for (NSString * title in titles){
			[self addToken:title];
		}
	}
    
    self.text = textEmpty;
    
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]){
		[self.delegate tokenFieldDidBeginEditing:self];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField {
	[self processLeftoverText:aTextField.text];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)aTextField {
	if ([self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)]){
		[self.delegate tokenFieldDidEndEditing:self];
	}
}

- (void)textFieldDidChange:(UITextField *)aTextField {
	if ([aTextField.text isEqualToString:@""] || aTextField.text.length == 0){
		[aTextField setText:textEmpty];
	}
}

- (BOOL)textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqualToString:@""] && [aTextField.text isEqualToString:textEmpty] && self.tokensArray.count){
		//When the backspace is pressed, we capture it, highlight the last token, and hide the cursor.
		TIToken * tok = [self.tokensArray lastObject];
        tok.highlighted = YES;
		[self setText:textHidden];
		
		return NO;
	}
	
	if ([aTextField.text isEqualToString:textHidden] && ![string isEqualToString:@""]){
		// When the text is hidden, we don't want the user to be able to type anything.
		return NO;
	}
	
	if ([aTextField.text	isEqualToString:textHidden] && [string isEqualToString:@""]){
		// When the user presses backspace and the text is hidden,
		// we find the highlighted token, and remove it.
		for (TIToken * tok in [NSArray arrayWithArray:self.tokensArray]){
			if (tok.highlighted){
				[self removeToken:tok];
				return NO;
			}
		}
	}
	
	if ([string isEqualToString:@","]){
		[self processLeftoverText:aTextField.text];
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[self processLeftoverText:aTextField.text];
	
	return YES;
}

#pragma mark -
#pragma mark Keyboard

#pragma mark -
#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
	if (self.keyboardShown) {
		return;
	}
	
	NSDictionary *userInfo = [notification userInfo]; 
	NSValue* keyboardOriginValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]; 
	CGRect keyboardRect = [self convertRect:[keyboardOriginValue CGRectValue] fromView:nil];
	CGFloat keyboardTop = keyboardRect.origin.y;
	
	// This assumes that no one else cares about the table view's insets...
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 
										   0, 
										   keyboardTop + 30.0, 
										   0);
	
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration; [animationDurationValue getValue:&animationDuration];
	[UIView beginAnimations:nil context:NULL]; 
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:animationDuration];
    
    self.contentOffset = CGPointMake(0.0, cursorLocation.y);
	
	[self setContentInset:insets];
	[self setScrollIndicatorInsets:insets];
	
	[UIView commitAnimations];
	
	self.keyboardShown = TRUE;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	if (!self.keyboardShown) {
		return;
	}
	
	// This assumes that no one else cares about the table view's insets...
	NSDictionary *userInfo = [notification userInfo]; 
	
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration; [animationDurationValue getValue:&animationDuration];
	[UIView beginAnimations:nil context:NULL]; 
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[self setContentInset:UIEdgeInsetsZero];
    [self setScrollIndicatorInsets:UIEdgeInsetsZero];
	
	[UIView commitAnimations];
	
	self.keyboardShown = FALSE;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize titleSize = [self.promptLabel.text sizeWithFont:[UIFont systemFontOfSize:17]];
    self.promptLabel.frame = CGRectMake(8, 11, titleSize.width , titleSize.height);
    
    // Adapted from Joe Hewitt's Three20 layout method.
	
	CGFloat fontHeight = (self.textField.font.ascender - self.textField.font.descender) + 1;
	CGFloat lineHeight = fontHeight + 15;
	CGFloat topMargin = floor(fontHeight / 1.75);
	CGFloat leftMargin = self.promptLabel.text.length > 0 ? self.promptLabel.frame.size.width + 12 : 8;
	CGFloat rightMargin = 10;
	CGFloat initialPadding = 8;
	CGFloat tokenPadding = 4;
	
	numberOfLines = 1;
	cursorLocation.x = leftMargin;
	cursorLocation.y = topMargin - 1;
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	
	for (TIToken * token in tokens){
		
		CGFloat lineWidth = cursorLocation.x + token.frame.size.width + rightMargin;
		
		if (lineWidth >= self.frame.size.width){
			
			numberOfLines++;
			cursorLocation.x = leftMargin;
			
			if (numberOfLines > 1){
				cursorLocation.x = initialPadding;
			}
			
			cursorLocation.y += lineHeight;
		}
		
		CGRect oldFrame = CGRectMake(token.frame.origin.x, token.frame.origin.y, token.frame.size.width, token.frame.size.height);
		CGRect newFrame = CGRectMake(cursorLocation.x, cursorLocation.y, token.frame.size.width, token.frame.size.height);
		
		if (!CGRectEqualToRect(oldFrame, newFrame)){
			
			[token setFrame:newFrame];
			[token setAlpha:0.6];
			
			[UIView animateWithDuration:0.3 animations:^{[token setAlpha:1];}];
		}
		
		cursorLocation.x += token.frame.size.width + tokenPadding;
		
	}
	
	[tokens release];
	
	CGFloat leftoverWidth = self.frame.size.width - (cursorLocation.x + rightMargin);
	
	if (leftoverWidth < 50){
		
		numberOfLines++;
		cursorLocation.x = leftMargin;
		
		if (numberOfLines > 1){
			cursorLocation.x = initialPadding;
		}
		
		cursorLocation.y += lineHeight;
	}
    
    if ([self.textField.text isEqualToString:textHidden]){
		self.textField.frame =  CGRectMake(-1000, -1000, 0, 0);
	} else {
        CGSize boundsSize = self.bounds.size;
        
        [self.textField sizeToFit];
        CGRect textFieldFrame = self.textField.frame;
        textFieldFrame.origin.x = cursorLocation.x;
        textFieldFrame.origin.y = cursorLocation.y + 3;
        textFieldFrame.size.width = boundsSize.width - cursorLocation.x - 8;
        self.textField.frame = CGRectIntegral(textFieldFrame);
    }
    
    CGFloat height = cursorLocation.y + fontHeight + topMargin + 5;
    if (self.contentSize.height != height) {
        self.contentSize = CGSizeMake(self.bounds.size.width, height);
    }
}

#pragma mark -
#pragma mark Responders

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return [self.textField canBecomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [self.textField resignFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return [self.textField canResignFirstResponder];
}

#pragma mark -
#pragma mark Description

- (NSString *)description {
	
	return [NSString stringWithFormat:@"<TITokenField %p 'Prompt: %@'>", self, ((UILabel *)[self viewWithTag:123]).text];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    self.delegate = nil;
    [tokensArray release];
    
    [super dealloc];
}

@end

#pragma mark -
#pragma mark TIToken

#define TokenTitleFont [UIFont systemFontOfSize:14]

@implementation TIToken
@synthesize highlighted;
@synthesize title;
@synthesize delegate;
@synthesize croppedTitle;

- (id)initWithTitle:(NSString *)aTitle {
	
	if ((self = [super init])){
		
		[self setTitle:aTitle];
		[self setCroppedTitle:aTitle];
		
		if ([aTitle length] > 24){
			NSString * shortTitle = [aTitle substringWithRange:NSMakeRange(0, 24)];
			[self setCroppedTitle:[NSString stringWithFormat:@"%@...", shortTitle]];
		}
		
		CGSize tokenSize = [croppedTitle sizeWithFont:TokenTitleFont];
		
		//We lay the tokens out all at once, so it doesn't matter what the X,Y coords are.
		[self setFrame:CGRectMake(0, 0, tokenSize.width + 17, tokenSize.height + 8)];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGSize titleSize = [croppedTitle sizeWithFont:TokenTitleFont];
	
	CGRect bounds = CGRectMake(0, 0, titleSize.width + 17, titleSize.height + 5);
	CGRect textBounds = bounds;
	textBounds.origin.x = (bounds.size.width - titleSize.width) / 2;
	textBounds.origin.y += 4;
	
	float arcValue = (bounds.size.height / 2) + 1;
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGPoint endPoint = CGPointMake(1, self.frame.size.height + 10);
	
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddArc(context, arcValue, arcValue, arcValue, (M_PI / 2), (3 * M_PI / 2), NO);
	CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue, 3 * M_PI / 2, M_PI / 2, NO);
	CGContextClosePath(context);
	
	if (highlighted){
		CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.207 green:0.369 blue:1 alpha:1] CGColor]);
		CGContextFillPath(context);
		CGContextRestoreGState(context);
	}
	else
	{
		
		CGContextClip(context);
		CGFloat locations[2] = {0, 0.95};
		CGFloat components[8] = {0.631, 0.733, 1, 1, 0.463, 0.510, 0.839, 1};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
		CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
		CGGradientRelease(gradient);
		CGContextRestoreGState(context);
	}
	
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddArc(context, arcValue, arcValue, (bounds.size.height / 2), (M_PI / 2) , (3 * M_PI / 2), NO);
	CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue - 1, (3 * M_PI / 2), (M_PI / 2), NO);
	CGContextClosePath(context);
	
	CGContextClip(context);
	
	if (highlighted){
		
		CGFloat locations[2] = {0, 0.8};
		CGFloat components[8] = {0.365, 0.557, 1, 1, 0.251, 0.345, 1, 1};
		CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, components, locations, 2);
		CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
		CGGradientRelease(gradient);
		
		[[UIColor whiteColor] set];
		[croppedTitle drawInRect:textBounds withFont:[UIFont systemFontOfSize:14]];
	}
	else
	{
		
		CGFloat locations[2] = {0, 0.4};
		CGFloat components[8] = {0.867, 0.906, 0.973, 1, 0.737, 0.808, 0.945, 1};
		CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, components, locations, 2);
		CGContextDrawLinearGradient (context, gradient, CGPointZero, endPoint, 0);
		CGGradientRelease(gradient);
		
		[[UIColor blackColor] set];
		[croppedTitle drawInRect:textBounds withFont:TokenTitleFont];
	}
	
	CGColorSpaceRelease(colorspace);
	CGContextRestoreGState(context);
}

- (void)setHighlighted:(BOOL)flag {
	highlighted = flag;
	[self setNeedsDisplay];
    
    if (!flag && [delegate respondsToSelector:@selector(tokenLostFocus:)]){
		[delegate tokenLostFocus:self];
	} else if (flag && [delegate respondsToSelector:@selector(tokenGotFocus:)]){
		[delegate tokenGotFocus:self];
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TIToken %p '%@'>", self, title];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.delegate = nil;
	[croppedTitle release];
	[title release];
    [super dealloc];
}

@end