#import "BaseLoadingViewCenter.h"
#import "SynthesizeSingleton.h"

@implementation BaseLoadingViewCenter

SYNTHESIZE_SINGLETON_FOR_CLASS(BaseLoadingViewCenter)

@synthesize keyedObservers;

- (NSMutableDictionary *)keyedObservers
{
	// does not retain observers
	if (!keyedObservers) {
		keyedObservers = [[NSMutableDictionary alloc]init];
	}
	
	return keyedObservers;
}

- (void)addObserver:(NSObject *)observer forKey:(NSString *)key
{
	if (!observer || !key) {
		return;
	}
	
	NSMutableArray *observers = [NSMutableArray arrayWithArray:[self.keyedObservers valueForKey:key]];
	if (![observers containsObject:[NSValue valueWithNonretainedObject:observer]]) {
		// Don't want to retain the observer
		[observers addObject:[NSValue valueWithNonretainedObject:observer]];
	}
	[self.keyedObservers setValue:observers forKey:key];
}

- (void)removeObserver:(NSObject *)observer forKey:(NSString *)key
{
	if (!observer || !key) {
		return;
	}
	
	NSMutableArray *observers = [NSMutableArray arrayWithArray:[self.keyedObservers valueForKey:key]];
	[observers removeObject:[NSValue valueWithNonretainedObject:observer]];
	[self.keyedObservers setValue:observers forKey:key];
}

- (void)didStartLoadingForKey:(NSString *)key
{
	if (!key) {
		return;
	}
	
	NSArray *observers = [self.keyedObservers valueForKey:key];
	for (NSValue *value in observers) {
		id object = [value nonretainedObjectValue];
		[object baseLoadingViewCenterDidStartForKey:key];
	}
}

- (void)didStopLoadingForKey:(NSString *)key
{
	if (!key) {
		return;
	}
	
	NSArray *observers = [self.keyedObservers valueForKey:key];
	for (NSValue *value in observers) {
		id object = [value nonretainedObjectValue];
		[object baseLoadingViewCenterDidStopForKey:key];
	}
}

- (void)showErrorMsg:(NSString *)errorMsg forKey:(NSString *)key
{
	if (!key) {
		return;
	}
	
	NSArray *observers = [self.keyedObservers valueForKey:key];
	for (NSValue *value in observers) {
		id object = [value nonretainedObjectValue];
		[object baseLoadingViewCenterShowErrorMsg:errorMsg forKey:key];
	}
}

- (void)showErrorMsg:(NSString *)errorMsg details:(NSString *)details forKey:(NSString *)key
{
	if (!key) {
		return;
	}
	
	NSArray *observers = [self.keyedObservers valueForKey:key];
	for (NSValue *value in observers) {
		id object = [value nonretainedObjectValue];
		[object baseLoadingViewCenterShowErrorMsg:errorMsg details:details forKey:key];
	}
}

- (void)removeErrorMsgForKey:(NSString *)key
{
	if (!key) {
		return;
	}
	
	NSArray *observers = [self.keyedObservers valueForKey:key];
	for (NSValue *value in observers) {
		id object = [value nonretainedObjectValue];
		[object baseLoadingViewCenterRemoveErrorMsgForKey:key];
	}
}

- (void)dealloc
{
	[keyedObservers release];
	
	[super dealloc];
}

@end
