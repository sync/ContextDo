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

- (void)parseTasks:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];
	if ([responseString length] != 0)  {
		NSError *error = nil;
		
		SBJsonParser *json = [[[SBJsonParser alloc]init] autorelease];
		
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
		//	}
		
		
		NSMutableArray *content = [NSMutableArray array];
		
		NSArray *tasksArray = [[[json objectWithString:responseString error:&error]niledNull]valueForKey:@"task"];
		
		if (!error && tasksArray) {
			for (NSDictionary *taskDic in tasksArray) {
				NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
				// 2010-07-24T05:26:28Z
				[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
				Task *task = [Task taskWithId:[[taskDic valueForKey:@"id"]niledNull]
										 name:[[taskDic valueForKey:@"name"]niledNull] 
									 location:[[taskDic valueForKey:@"location"]niledNull]
								   modifiedAt:[dateFormatter dateFromString:[[taskDic valueForKey:@"updated_at"]niledNull]]];
				task.action = [[taskDic valueForKey:@"action"]niledNull];
				task.contactDetail = [[taskDic valueForKey:@"contact_detail"]niledNull];
				task.contactName = [[taskDic valueForKey:@"contact_name"]niledNull];
				task.dueAt = [dateFormatter dateFromString:[[taskDic valueForKey:@"due_at"]niledNull]];
				task.completedAt = [dateFormatter dateFromString:[[taskDic valueForKey:@"completed_at"]niledNull]];
				task.groupId = [[taskDic valueForKey:@"group_id"]niledNull];
				task.groupName = [[taskDic valueForKey:@"group_name"]niledNull];
				task.latitude = [[taskDic valueForKey:@"latitude"]niledNull];
				task.longitude = [[taskDic valueForKey:@"longitude"]niledNull];
				if (task) {
					[content addObject:task];
				}
			}
		}
		
		NSDictionary *info = request.userInfo;
		[self notifyDone:request object:[NSDictionary dictionaryWithObjectsAndKeys:
										 [NSArray arrayWithArray:content], @"tasks",
										 [info valueForKey:@"object"], @"object",
										 nil
										 ]];
	}
}


@end
