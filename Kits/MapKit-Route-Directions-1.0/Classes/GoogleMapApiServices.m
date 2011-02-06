#import "GoogleMapApiServices.h"
#import "JSON.h"

@interface GoogleMapApiServices ()

@property (nonatomic, readonly) ASINetworkQueue *networkQueue;
- (ASIHTTPRequest *)requestWithUrl:(NSString *)url;
- (void)parseDirections:(ASIHTTPRequest *)request;

@end

@implementation GoogleMapApiServices

@synthesize networkQueue;

#pragma mark -
#pragma mark Requests

#define GOOGLE_DIRECTIONS_PATH @"http://maps.googleapis.com/maps/api/directions/json?"

- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(NSString *)options
{
	NSString *url = [NSString stringWithFormat:@"%@origin=%@&destination=%@&sensor=false", 
					 GOOGLE_DIRECTIONS_PATH,
					 startPoint, 
					 endPoint, 
					 (options.length > 0) ? [NSString stringWithFormat:@"&%@", options] : @""
					 ];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	ASIHTTPRequest *request = [self requestWithUrl:url];
	request.delegate = self;
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
}

- (void)loadFromWaypoints:(NSArray *)waypoints options:(NSString *)options
{
	NSString *url = [NSString stringWithFormat:@"%@waypoints=optimize:true|%@&sensor=false", 
					 GOOGLE_DIRECTIONS_PATH,
					 [waypoints componentsJoinedByString:@"|"],
					 (options.length > 0) ? [NSString stringWithFormat:@"&%@", options] : @""
					 ];
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	ASIHTTPRequest *request = [self requestWithUrl:url];
	request.delegate = self;
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
}

#pragma mark -
#pragma mark Parsing

- (void)parseDirections:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];
	if ([responseString length] != 0 && request.responseStatusCode == 200)  {
		NSError *error = nil;
		
		SBJsonParser *json = [[[SBJsonParser alloc]init] autorelease];
		
		
		NSDictionary *directionsDict = (NSDictionary *)[json objectWithString:responseString error:&error];
		if (!error && directionsDict && ![directionsDict isKindOfClass:[NSNull class]]) {		
			[[NSNotificationCenter defaultCenter]postNotificationName:GoogleMapDirectionsApiNotificationDidSucceed object:directionsDict];
		} else {
			[[NSNotificationCenter defaultCenter]postNotificationName:GoogleMapDirectionsApiNotificationDidFailed object:responseString];
		}
	} else {
		[[NSNotificationCenter defaultCenter]postNotificationName:GoogleMapDirectionsApiNotificationDidFailed object:[request.error localizedDescription]];
	}
	
}

#pragma mark -
#pragma mark Boilerplate

- (ASIHTTPRequest *)requestWithUrl:(NSString *)url
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 1;
	request.timeOutSeconds = 45.0;
	
	request.allowCompressedResponse = TRUE;
	
	return request;
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate + Network Queue

- (ASINetworkQueue *)networkQueue
{
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];
		if ([self respondsToSelector:@selector(fetchCompleted:)]) {
			[networkQueue setRequestDidFinishSelector:@selector(fetchCompleted:)];
		}
		if ([self respondsToSelector:@selector(fetchFailed:)]) {
			[networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
		}
		
		[networkQueue setDelegate:self];
	}
	
	return networkQueue;
}

- (void)fetchCompleted:(ASIHTTPRequest *)request
{
	[self parseDirections:request];
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
	[[NSNotificationCenter defaultCenter]postNotificationName:GoogleMapDirectionsApiNotificationDidFailed object:[request.error localizedDescription]];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[networkQueue release];
	
    [super dealloc];
}


@end
