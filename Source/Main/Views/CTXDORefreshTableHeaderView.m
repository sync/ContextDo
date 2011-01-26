#import "CTXDORefreshTableHeaderView.h"

#define TEXT_COLOR	 [UIColor blackColor]
#define FLIP_ANIMATION_DURATION 0.18f

@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation CTXDORefreshTableHeaderView

@synthesize animView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		//hax
		for (UIView *view in [self subviews]) {
			[view removeFromSuperview];
		}
		// more hax
		for (CALayer *layer in self.layer.sublayers) {
			[layer removeFromSuperlayer];
		}
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.backgroundColor = [UIColor clearColor];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithHexString:@"FFFFFF40"];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithHexString:@"FFFFFF40"];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(15.0f, frame.size.height - 50.0f, 40.0f, 40.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"refresh1.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
//		
//		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
//		[self addSubview:view];
//		_activityView = view;
//		[view release];
		
		self.animView = [[[UIImageView alloc]initWithFrame:CGRectMake(15.0f, frame.size.height - 50.0f, 40.0f, 40.0f)]autorelease];
		NSMutableArray *images = [NSMutableArray array];;
		for (NSInteger i = 1; i<12; i++) {
			NSString *imageNamed = [NSString stringWithFormat:@"refresh%d.png", i];
			[images addObject:[UIImage imageNamed:imageNamed]];
		}
		self.animView.animationImages = images;
		self.animView.animationDuration = 0.5;
		[self addSubview:self.animView];
		
		
		[self setState:EGOOPullRefreshNormal];
		
    }
	
    return self;
	
}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			//[_activityView stopAnimating];
			[self.animView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			//[_activityView startAnimating];
			[self.animView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	[super drawRect:rect];
	
	NSString *topImageNamed = topImageNamed = @"refresh_bg_top.png";
	NSString *middleImageNamed = @"refresh_bg_middle.png";
	NSString *bottomImageNamed = @"refresh_bg_bottom.png";
	
	
	
	CGSize boundsSize = self.bounds.size;
	
	CGFloat topHeight = 0.0;
	
	if (TRUE) {
		UIImage *topImage = [UIImage imageNamed:topImageNamed];
		topImage = [topImage stretchableImageWithLeftCapWidth:(topImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
		[topImage drawInRect:CGRectMake(0.0, 
										0.0, 
										boundsSize.width, 
										topImage.size.height)];
		topHeight += topImage.size.height;
	}
	
	CGFloat bottomHeight = 0.0;
	
	if (TRUE) {
		UIImage *bottomImage = [UIImage imageNamed:bottomImageNamed];
		bottomImage = [bottomImage stretchableImageWithLeftCapWidth:(bottomImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
		[bottomImage drawInRect:CGRectMake(0.0, 
										   boundsSize.height - bottomImage.size.height, 
										   boundsSize.width, 
										   bottomImage.size.height)];
		bottomHeight += bottomImage.size.height;
	}
	
	if (TRUE) {
		UIImage *middleImage = [UIImage imageNamed:middleImageNamed];
		middleImage = [middleImage stretchableImageWithLeftCapWidth:(middleImage.size.width / 2.0) - 1.0 
													   topCapHeight:0.0];
		[middleImage drawInRect:CGRectMake(0.0, 
										   topHeight, 
										   boundsSize.width, 
										   boundsSize.height - topHeight - bottomHeight)];
	}
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		UIEdgeInsets contentInset = scrollView.contentInset;
		contentInset.top = offset;
		scrollView.contentInset = contentInset;
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			UIEdgeInsets contentInset = scrollView.contentInset;
			contentInset.top = 0.0;
			scrollView.contentInset = contentInset;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		UIEdgeInsets contentInset = scrollView.contentInset;
		contentInset.top = 60.0;
		scrollView.contentInset = contentInset;
		[UIView commitAnimations];
		
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	UIEdgeInsets contentInset = scrollView.contentInset;
	contentInset.top = 0.0;
	scrollView.contentInset = contentInset;
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
	
}

@end
