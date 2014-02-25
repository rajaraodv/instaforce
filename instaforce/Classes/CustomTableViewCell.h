//
//  CustomTableViewCell.h
//  instaforce
//
//  Created by Raja Rao DV on 2/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LikesButtonDelegate <NSObject>;

-(void)likeButtonClickedOnCell:(id) cell;

@end

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic,strong) id <LikesButtonDelegate> delegate;


@property(strong, nonatomic) IBOutlet UIImageView *myImageView;


@property(strong, nonatomic) IBOutlet UILabel *Owner;

@property(strong, nonatomic) IBOutlet UIImageView *ownerImageView;

- (IBAction)likesBtnPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *likeBtnLabel;

@end
