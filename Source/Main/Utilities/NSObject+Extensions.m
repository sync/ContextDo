#import "NSObject+Extensions.h"


@implementation NSObject (Extensions)

- (id)niledNull
{
	if ([self isKindOfClass:[NSNull class]]) {
		return nil;
	}
	
	return self;
}

@end
