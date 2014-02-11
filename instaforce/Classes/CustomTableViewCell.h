//
//  CustomTableViewCell.h
//  instaforce
//
//  Created by Raja Rao DV on 2/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *myImageView;

@property (strong, nonatomic) IBOutlet UILabel *ownerName;

@property (strong, nonatomic) IBOutlet UILabel *fileName;

@end