#import <Foundation/Foundation.h>


@interface UIImage (Extensions)

- (CGImageRef)createMaskedImageRef:(UIImage *)maskImage;

@end
