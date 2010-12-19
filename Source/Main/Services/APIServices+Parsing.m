#import "APIServices+Parsing.h"
#import "APIServices+Utils.h"
#import "JSON.h"

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
	NSString *responseString = [request responseString];
	if ([responseString length] != 0)  {
		NSError *error = nil;
		
		SBJsonParser *json = [[[SBJsonParser alloc]init] autorelease];
		
		//	"group": {
		//		"created_at": "2010-12-19T05:21:31Z",
		//		"id": 2,
		//		"name": "Foo",
		//		"updated_at": "2010-12-19T05:21:31Z"
		//	}
		
		NSMutableArray *content = [NSMutableArray array];
		
		NSArray *groupsArray = [[[json objectWithString:responseString error:&error]niledNull]valueForKey:@"group"];
		
		if (!error && groupsArray) {
			for (NSDictionary *groupDict in groupsArray) {
				NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
				// 2010-07-24T05:26:28Z
				[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
				Group *group = [Group groupWithId:[[groupDict valueForKey:@"id"]niledNull]
											 name:[[groupDict valueForKey:@"name"]niledNull]
									   modifiedAt:[dateFormatter dateFromString:[[groupDict valueForKey:@"updated_at"]niledNull]]];
				if (group) {
					[content addObject:group];
				}
			}
		}
		
		NSDictionary *info = request.userInfo;
		[self notifyDone:request object:[NSDictionary dictionaryWithObjectsAndKeys:
										 [NSArray arrayWithArray:content], @"groups",
										 [info valueForKey:@"object"], @"object",
										 nil
										 ]];
	}
}


@end
