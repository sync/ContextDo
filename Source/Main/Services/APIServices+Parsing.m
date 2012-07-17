#import "APIServices+Parsing.h"
#import "BaseASIServices+Utils.h"
#import "ObjectiveSupport.h"

@implementation APIServices (parsing)

#pragma mark -
#pragma mark Credentials

- (void)parseResetPassword:(ASIHTTPRequest *)request
{
	if (request.responseStatusCode >= 400)  {
        [self notifyFailed:request withError:@"Unable to Reset Password!"];
	} else {
		[self notifyDone:request withObject:nil];
	}
}

#pragma mark -
#pragma mark Groups

- (void)parseGroups:(ASIHTTPRequest *)request
{
	if ([request.responseData length] != 0)  {
		
		//	"group": {
		//		"created_at": "2011-01-18T15:36:43Z",
		//		"id": 17,
		//		"name": "Test",
		//		"position": 1,
		//		"updated_at": "2011-01-18T15:36:43Z",
		//		"user_id": 2,
		//		"expired_count": 0,
		//		"due_count": 0
		//	}
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		NSArray *content = [NSArray fromJSONData:request.responseData];
		
		[self notifyDone:request withObject:content];
	}
}

- (void)parseGroup:(ASIHTTPRequest *)request
{
	if ([request.responseData length] != 0)  {
		
		//	"group": {
		//		"created_at": "2011-01-18T15:36:43Z",
		//		"id": 17,
		//		"name": "Test",
		//		"position": 1,
		//		"updated_at": "2011-01-18T15:36:43Z",
		//		"user_id": 2,
		//		"expired_count": 0,
		//		"due_count": 0
		//	}
		
		if ([[self notificationNameForRequest:request]isEqualToString:GroupDeleteNotification]) {
			[self notifyDone:request withObject:nil];
			return;
		}
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		Group *group = [Group fromJSONData:request.responseData];
		if (group) {
			[self notifyDone:request withObject:group];
		} else {
			if ([[self notificationNameForRequest:request]isEqualToString:GroupAddNotification]) {
				[self notifyFailed:request withError:@"Unable to Create Group"];
			} else {
				[self notifyFailed:request withError:@"Unable to Modify Group"];
			}
			
		}
	}
}

#pragma mark -
#pragma mark Tasks

- (void)parseTasks:(ASIHTTPRequest *)request
{
	if (request.responseData != 0)  {
	
		//	task: {
		//		action: null
		//		completed_at: null
		//		contact_detail: null
		//		contact_name: null
		//		created_at: 2010-12-20T00:26:18Z
		//		due_at: 2010-12-21T10:26:00Z
		//		group_id: 12
		//			id: 3
		//		info: null
		//		latitude: -27.4655769
		//		location: Brisbane QLD 4005, Australia
		//		longitude: 153.0471371
		//		name: Pack bags
		//		updated_at: 2011-01-20T05:07:45Z
		//		group_name: Shopping
		//	}
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		NSArray *content = [NSArray fromJSONData:request.responseData];
		
		[self notifyDone:request withObject:content];
	}
}

- (void)parseTask:(ASIHTTPRequest *)request
{
	if ([request.responseData length] != 0)  {
		
		//	task: {
		//		action: null
		//		completed_at: null
		//		contact_detail: null
		//		contact_name: null
		//		created_at: 2010-12-20T00:26:18Z
		//		due_at: 2010-12-21T10:26:00Z
		//		group_id: 12
		//			id: 3
		//		info: null
		//		latitude: -27.4655769
		//		location: Brisbane QLD 4005, Australia
		//		longitude: 153.0471371
		//		name: Pack bags
		//		updated_at: 2011-01-20T05:07:45Z
		//		group_name: Shopping
		//	}
        
        // [request responseStatusCode] == 422 ==> quick hack don't do this
        if ([request responseStatusCode] == 422) {
			[self notifyFailed:request withError:@"Unable to Create Task"];
			return;
		}
        
		if ([[self notificationNameForRequest:request]isEqualToString:TaskDeleteNotification]) {
			[self notifyDone:request withObject:nil];
			return;
		}
        
        // [request responseStatusCode] == 422 ==> quick hack don't do this
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		Task *task = [Task fromJSONData:request.responseData];
        if (task) {
			[self notifyDone:request withObject:task];
		} else {
			if ([[self notificationNameForRequest:request]isEqualToString:TaskAddNotification]) {
				[self notifyFailed:request withError:@"Unable to Create Task"];
			} else {
				[self notifyFailed:request withError:@"Unable to Modify Task"];
			}
			
		}
	}
}

- (void)parseUser:(ASIHTTPRequest *)request
{
	if ([request.responseData length] != 0)  {
		
		// check fix from bo todo, got empty dict back
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		User *user = [User fromJSONData:request.responseData];
		if (![user.userId isEqual:self.user.userId]) {
            // here clear data?
		}
		self.user = user;
		if (user) {
			[self notifyDone:request withObject:user];
		} else {
			if ([[self notificationNameForRequest:request]isEqualToString:UserEditNotification]) {
				[self notifyFailed:request withError:@"Unable to Edit Settings"];
			}
			
		}
	}
}

@end
