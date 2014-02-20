//
//  CameraViewController.m
//  instaforce
//
//  Created by Raja Rao DV on 2/7/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

#import "FilterViewController.h"



@interface CameraViewController ()

@end

@implementation CameraViewController


- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController setSelectedIndex:0];

    [super viewWillAppear:animated];
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
    
    [self presentViewController:self.imagePicker animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - ImagePickerControllerDelegate

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self dismissViewControllerAnimated:NO completion:^{
            
            [self performSegueWithIdentifier:@"ShowFilterViewSegue" sender:self];
        }];
    }
}

#pragma mark - segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"ShowFilterViewSegue"]) {
        [[segue destinationViewController] setOriginalImage:self.image] ;
    }
}

@end
