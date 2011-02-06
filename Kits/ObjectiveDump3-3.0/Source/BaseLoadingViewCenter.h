#import <Foundation/Foundation.h>

@interface BaseLoadingViewCenter : NSObject {
}

+ (BaseLoadingViewCenter *)sharedBaseLoadingViewCenter;

@property (nonatomic, readonly) NSMutableDictionary *keyedObservers;

- (void)addObserver:(NSObject *)observer forKey:(NSString *)key;
- (void)removeObserver:(NSObject *)observer forKey:(NSString *)key;

- (void)didStartLoadingForKey:(NSString *)key;
- (void)didStopLoadingForKey:(NSString *)key;
- (void)showErrorMsg:(NSString *)errorMsg forKey:(NSString *)key;
- (void)showErrorMsg:(NSString *)errorMsg details:(NSString *)details forKey:(NSString *)key;
- (void)removeErrorMsgForKey:(NSString *)key;

@end


@protocol BaseLoadingViewCenterDelegate <NSObject>

@required
- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key;
- (void)baseLoadingViewCenterDidStopForKey:(NSString *)key;
- (void)baseLoadingViewCenterShowErrorMsg:(NSString *)errorMsg forKey:(NSString *)key;
- (void)baseLoadingViewCenterShowErrorMsg:(NSString *)errorMsg details:(NSString *)details forKey:(NSString *)key;
- (void)baseLoadingViewCenterRemoveErrorMsgForKey:(NSString *)key;

@end