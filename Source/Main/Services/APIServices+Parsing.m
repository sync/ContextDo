#import "APIServices+Parsing.h"
#import "APIServices+Utils.h"
#import "JSON.h"
#import "NSObject+JSONSerializableSupport.h"
#import "ObjectiveResourceDateFormatter.h"

@implementation APIServices (parsing)

- (void)parseLogin:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];
	if ([responseString length] != 0 && request.responseStatusCode == 200)  {
		NSError *error = nil;
		
		SBJsonParser *json = [[[SBJsonParser alloc]init] autorelease];
		
		// {"api_token":"H3dU4mqVrpBoh9qZQ9TO"}
		
		NSString *apiToken = [(NSString *)[[[json objectWithString:responseString error:&error]niledNull]valueForKey:@"api_token"]niledNull];
		if (!error && apiToken) {		
			self.username = request.username;
			self.password = request.password;
			self.apiToken = apiToken;
			[self notifyDone:request object:nil];
		} else {
			[self notifyFailed:request withError:@"Unable to Login!"];
		}
	} else {
		[self notifyFailed:request withError:@"Unable to Login!"];
	}
	
}

- (void)parseRegister:(ASIHTTPRequest *)request
{
	NSDictionary *info = request.userInfo;
	
	if (request.responseStatusCode != 500)  {
		self.username = [info valueForKey:@"username"];
		self.password = [info valueForKey:@"password"];
		[self notifyDone:request object:nil];
	} else {
		[self notifyFailed:request withError:@"Account already exists!"];
	}
}

- (void)parseResetPassword:(ASIHTTPRequest *)request
{
	if (request.responseStatusCode != 500)  {
		[self notifyDone:request object:nil];
	} else {
		[self notifyFailed:request withError:@"Unable to Reset Password!"];
	}
}

- (void)parseGroups:(ASIHTTPRequest *)request
{
	if ([request.responseData length] != 0)  {
		
		//	"group": {
		//		"created_at": "2010-12-19T05:21:31Z",
		//		"id": 2,
		//		"name": "Foo",
		//		"updated_at": "2010-12-19T05:21:31Z"
		//	}
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		NSArray *content = [NSArray fromJSONData:request.responseData];

		
		NSDictionary *info = request.userInfo;
		[self notifyDone:request object:[NSDictionary dictionaryWithObjectsAndKeys:
										 content, @"groups",
										 [info valueForKey:@"object"], @"object",
										 nil
										 ]];
	}
}

- (void)parseTasks:(ASIHTTPRequest *)request
{
	if (request.responseData != 0)  {
	
		//	"task": {
		//		"action": null, 
		//		"contact_detail": "0412639224", 
		//		"contact_name": "Bodaniel Jeanes", 
		//		"created_at": "2010-12-19T08:16:49Z", 
		//		"due_at": "2010-12-25T00:01:00Z", 
		//		"group_id": 1, 
		//		"group_name": "Foo", 
		//		"id": 1, 
		//		"latitude": -27.451533000000001, 
		//		"location": "38 Skyring Terrace, Newstead QLD 4006, Australia", 
		//		"longitude": 153.04731799999999, 
		//		"name": "My Task", 
		//		"updated_at": "2010-12-19T08:19:22Z"
		//		"completed_at": "2010-12-19T08:19:22Z"
		//	}
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		NSArray *content = [NSArray fromJSONData:request.responseData];
		
		NSDictionary *info = request.userInfo;
		[self notifyDone:request object:[NSDictionary dictionaryWithObjectsAndKeys:
										 content, @"tasks",
										 [info valueForKey:@"object"], @"object",
										 nil
										 ]];
	}
}


@end
