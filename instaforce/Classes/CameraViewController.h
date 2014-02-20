//
//  CameraViewController.h
//  instaforce
//
//  Created by Raja Rao DV on 2/7/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"




@interface CameraViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) UIImage *image;
@end
