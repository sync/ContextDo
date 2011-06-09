//
//  TasksSearchViewController.m
//  ContextDo
//
//  Created by Anthony Mittaz on 9/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TasksSearchViewController.h"

@implementation TasksSearchViewController

@synthesize searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Search Task";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.searchBar = nil;
}

- (void)dealloc
{
    [searchBar release];
    
    [super dealloc];
}

@end
