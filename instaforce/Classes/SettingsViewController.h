//
//  SettingsViewController.h
//  instaforce
//
//  Created by Raja Rao DV on 2/21/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SFRestDelegate>

@property (atomic, strong) NSString* selectedGroupId;
@property (atomic, strong) NSMutableArray* groups;
@end
