//
//  SubmitPostViewController.h
//  instaforce
//
//  Created by Raja Rao DV on 2/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@interface SubmitPostViewController : UIViewController <SFRestDelegate>

- (IBAction)cancelBtn:(id)sender;

- (IBAction)submitBtn:(id)sender;

@property(strong, nonatomic) IBOutlet UITextView *postTextView;

@property(strong, nonatomic) IBOutlet UIImageView *modifiedImageView;

@property(strong, nonatomic) UIImage *modifiedImage;

@end
