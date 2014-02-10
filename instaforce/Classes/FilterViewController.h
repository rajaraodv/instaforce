//
//  FilterViewController.h
//  instaforce
//
//  Created by Raja Rao DV on 2/9/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface FilterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIImage * originalImage;

@property (atomic,strong) UIImage* modifiedImage;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)cancelBtn:(id)sender;

@property (strong, nonatomic) NSArray *filtersArray;

@end
