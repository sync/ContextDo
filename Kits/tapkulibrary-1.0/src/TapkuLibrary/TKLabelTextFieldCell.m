//
//  TKLabelTextfieldCell.m
//  Created by Devin Ross on 7/1/09.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKLabelTextFieldCell.h"


@implementation TKLabelTextFieldCell
@synthesize field;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
	
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		field = [[UITextField alloc] initWithFrame:CGRectZero];
		field.autocorrectionType = UITextAutocorrectionTypeYes;
		field.delegate = self;
		[self addSubview:field];
		//field.backgroundColor = [UIColor redColor];
		field.font = [UIFont boldSystemFontOfSize:16.0];
		
    }
    return self;
	
	
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		field = [[UITextField alloc] initWithFrame:CGRectZero];
		field.autocorrectionType = UITextAutocorrectionTypeYes;
		field.delegate = self;
		[self addSubview:field];
		//field.backgroundColor = [UIColor redColor];
		field.font = [UIFont boldSystemFontOfSize:16.0];
		
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGRect r = CGRectInset(self.bounds, 16, 8);
	r.origin.y += 5;
	r.size.height -= 5;
	r.origin.x += 80;
	r.size.width -= 80;
	
	if(self.editing){
		r.origin.x += 30;
		r.size.width -= 30;
	}
	
	
	field.frame = r;
	
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[field resignFirstResponder];
	return NO;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state{
	[super willTransitionToState:state];
	[self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
	if(selected){
		field.textColor = [UIColor whiteColor];
	}else{
		field.textColor = [UIColor blackColor];
	}
	
}
- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
	[super setHighlighted:highlighted animated:animated];
	if(highlighted){
		field.textColor = [UIColor whiteColor];
	}else{
		field.textColor = [UIColor blackColor];
	}
}


- (void)dealloc {
	[field release];
	[super dealloc];
}


@end
