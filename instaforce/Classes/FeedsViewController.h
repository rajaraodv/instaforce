//
//  FeedsViewController.h
//  instaforce
//
//  Created by Raja Rao DV on 2/7/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "CustomTableViewCell.h"

@interface FeedsViewController : UITableViewController<SFRestDelegate> {

    NSMutableArray *dataRows;
    IBOutlet UITableView *tableView;

}

@property (nonatomic, strong) NSArray *dataRows;

@end