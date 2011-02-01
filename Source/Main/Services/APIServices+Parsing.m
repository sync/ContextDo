#import "APIServices+Parsing.h"
#import "BaseASIServices+Utils.h"

@implementation APIServices (parsing)

#pragma mark -
#pragma mark Credentials

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
		NSDictionary *dict = [NSDictionary dictionaryWithContent:content date:[NSDate date]];
		[[CacheServices sharedCacheServices].groupsDict addEntriesFromDictionary:dict];
		[[CacheServices sharedCacheServices] saveGroupsDict];
		
		[self notifyDone:request object:content];
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
		
		NSDictionary *info = request.userInfo;
		
		if ([[self notificationNameForRequest:request]isEqualToString:GroupDeleteNotification]) {
			[self notifyDone:request object:nil];
			return;
		}
		
		Group *nonSyncedGroup = [info valueForKey:@"object"];
		NSString *notificationName = [self notificationNameForRequest:request]; 
		if ([notificationName isEqualToString:GroupAddNotification]) {
			[[CacheServices sharedCacheServices].groupsOutOfSyncDict removeObjectUnderArray:nonSyncedGroup forKey:AddedKey];
		} else if ([notificationName isEqualToString:GroupEditNotification]) {
			[[CacheServices sharedCacheServices].groupsOutOfSyncDict removeObjectUnderArray:nonSyncedGroup forKey:UpdatedKey];
		} else if ([notificationName isEqualToString:GroupDeleteNotification]) {
			[[CacheServices sharedCacheServices].groupsOutOfSyncDict removeObjectUnderArray:nonSyncedGroup forKey:DeletedKey];
		}
		
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		Group *group = [Group fromJSONData:request.responseData];
		if (group) {
			if ([notificationName isEqualToString:GroupAddNotification]) {
				[[CacheServices sharedCacheServices] addCachedGroup:group syncId:nonSyncedGroup.syncId];
			} else if ([notificationName isEqualToString:GroupEditNotification]) {
				[[CacheServices sharedCacheServices] updateCachedGroup:group syncId:nonSyncedGroup.syncId];
			} else if ([notificationName isEqualToString:GroupDeleteNotification]) {
				[[CacheServices sharedCacheServices] deleteCachedGroup:group syncId:nonSyncedGroup.syncId];
			}
			[self notifyDone:request object:[NSDictionary dictionaryWithObjectsAndKeys:
											 group, @"object",
											 [info valueForKey:@"object"], @"group",
											 nil
											 ]];
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
		
		NSDictionary *info = request.userInfo;
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		NSArray *content = [NSArray fromJSONData:request.responseData];

		NSString *key = [info valueForKey:@"object"];
		NSString *notificationName = [self notificationNameForRequest:request];
		if ([notificationName isEqualToString:TasksDidLoadNotification]) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:content date:[NSDate date]];
			[[CacheServices sharedCacheServices].tasksWithGroupIdDict setValue:dict forKey:key];
			[[CacheServices sharedCacheServices] saveTasksWithGroupId];
		} else if ([notificationName isEqualToString:TasksDueDidLoadNotification]) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:content date:[NSDate date]];
			[[CacheServices sharedCacheServices].tasksWithDueDict setValue:dict forKey:key];
			[[CacheServices sharedCacheServices] saveTasksWithDue];
		} else if ([notificationName isEqualToString:TasksDueTodayDidLoadNotification]) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:content date:[NSDate date]];
			[[CacheServices sharedCacheServices].tasksDueTodayDict removeAllObjects];
			[[CacheServices sharedCacheServices].tasksDueTodayDict setValue:dict forKey:key];
			[[CacheServices sharedCacheServices] saveTasksDueToday];
		} else if ([notificationName isEqualToString:TasksWithinDidLoadNotification]) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:content date:[NSDate date]];
			[[CacheServices sharedCacheServices].tasksWithLatitudeDict removeAllObjects];
			[[CacheServices sharedCacheServices].tasksWithLatitudeDict setValue:dict forKey:key];
			[[CacheServices sharedCacheServices] saveTasksWithLatitude];
		} if ([notificationName isEqualToString:TasksUpdatedSinceDidLoadNotification]) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:content date:[NSDate date]];
			[[CacheServices sharedCacheServices].editedTasksDict removeAllObjects];
			[[CacheServices sharedCacheServices].editedTasksDict setValue:dict forKey:key];
			[[CacheServices sharedCacheServices] saveEditedTasks];
		}
		
		
		[self notifyDone:request object:[NSDictionary dictionaryWithObjectsAndKeys:
										 content, @"tasks",
										 [info valueForKey:@"object"], @"object",
										 nil
										 ]];
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
		
		if ([[self notificationNameForRequest:request]isEqualToString:TaskDeleteNotification]) {
			[self notifyDone:request object:nil];
			return;
		}
		
		[ObjectiveResourceDateFormatter setSerializeFormat:DateTime];
		Task *task = [Task fromJSONData:request.responseData];
		if (task) {
			[self notifyDone:request object:task];
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
			[[CacheServices sharedCacheServices] clearCachedData];
		}
		self.user = user;
		if (user) {
			[self notifyDone:request object:user];
		} else {
			if ([[self notificationNameForRequest:request]isEqualToString:UserEditNotification]) {
				[self notifyFailed:request withError:@"Unable to Edit Settings"];
			}
			
		}
	}
}

@end
