#import "UIImage+Extensions.h"


@implementation UIImage (Extensions)

- (CGImageRef)createMaskedImageRef:(UIImage *)maskImage
{
	// Masked image
	CGImageRef imageRef = [self CGImage];
	CGImageRef maskRef = [maskImage CGImage];
	
	// Create mask
	CGImageRef xMaskedImage = CGImageCreateWithMask(imageRef,maskRef);
	return xMaskedImage;
}

@end
