//
//  TasksSearchViewController.h
//  ContextDo
//
//  Created by Anthony Mittaz on 9/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

@interface TasksSearchViewController : BaseTableViewController <UISearchBarDelegate> {

}

@property (nonatomic, retain) IBOutlet UISearchBar * searchBar;

@end
