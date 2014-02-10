//
//  CameraViewController.m
//  instaforce
//
//  Created by Raja Rao DV on 2/7/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

#import "SFRestAPI.h"
#import "SFRestAPI+Files.h"
#import "SFRestRequest.h"
#import "FilterViewController.h"


#define ME @"me"
#define PAGE @"page"
#define VERSION @"versionNumber"
#define CONTENT_DOCUMENT_ID @"ContentDocumentId"
#define LINKED_ENTITY_ID @"LinkedEntityId"
#define SHARE_TYPE @"ShareType"
#define RENDITION_TYPE @"type"
#define FILE_DATA @"fileData"
#define TITLE @"title"
#define DESCRIPTION @"desc"


@interface CameraViewController ()

@end

@implementation CameraViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated {
     [super viewDidAppear:animated];
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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
       // [self.tabBarController setSelectedIndex:0];
        

        
        //UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
       // [self uploadImageToSalesforce];
    }
    
    
   // [self dismissViewControllerAnimated:YES completion:nil];
    //[self.tabBarController setSelectedIndex:0];
    
}


- (void) uploadImageToSalesforce {
    
    NSLog(@"Doing upload");

    NSData *data = UIImageJPEGRepresentation(self.image, 0.5);
//    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUploadFile:data
//                                                    name:@"123"
//                                             description:@"123"
//                                                mimeType:@"image/jpeg"];

    SFRestRequest *request = [self requestForUploadFile:data name:@"123"
                                                            description:@"123"
                                                            mimeType:@"image/jpeg"];

    
  [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - SFRestAPIDelegate

//- (SFRestRequest *) requestForUploadFile:(NSData *)data name:(NSString *)name description:(NSString *)description mimeType:(NSString *)mimeType {
//    NSString *path = [NSString stringWithFormat:@"/%@/chatter/users/me/files", @"v28.0"];
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    if (name) [params setObject:name forKey:TITLE];
//    if (description) [params setObject:description forKey:DESCRIPTION];
//    
//    NSData *jsonNSData = [NSData dataWithContentsOfFile:@"/Users/rraodv/apps/instaforce/fdata.json"];
//    NSError *error = nil;
//    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonNSData options:kNilOptions error:&error];
//    
//    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:dictionary];
//    [request addPostFileData:data paramName:FILE_DATA fileName:name mimeType:mimeType];
//    return request;
//}

- (SFRestRequest *) requestForUploadFile:(NSData *)data name:(NSString *)name description:(NSString *)description mimeType:(NSString *)mimeType {
    NSString *path = [NSString stringWithFormat:@"/%@/chatter/feeds/user-profile/me/feed-items", @"v29.0"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) [params setObject:name forKey:TITLE];
    if (description) [params setObject:description forKey:DESCRIPTION];
    
    NSData *jsonNSData = [NSData dataWithContentsOfFile:@"/Users/rraodv/apps/instaforce/data.json"];
    NSError *error = nil;
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonNSData options:kNilOptions error:&error];
    
    NSLog(@"%@", dictionary);
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:dictionary];
    [request addPostFileData:data paramName:@"feedItemFileUpload" fileName:name mimeType:mimeType];
    return request;
}




- (void)request:(SFRestRequest *)request didLoadResponse:(id)dataResponse {

    NSLog(@"%@", dataResponse);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.imageView.image = [UIImage imageWithData:dataResponse];
//        
//    });
    //    NSArray *records = [jsonResponse objectForKey:@"records"];
    //    NSLog(@"%@", jsonResponse);
    //    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    //    self.dataRows = records;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self.tableView reloadData];
    //    });
}


//- (SFRestRequest *) requestForUploadFile:(NSData *)data name:(NSString *)name description:(NSString *)description mimeType:(NSString *)mimeType {
//    NSString *path = [NSString stringWithFormat:@"/%@/chatter/feeds/user-profile/me/feed-items", @"v28.0"];
//    
////    NSMutableDictionary *params = [NSMutableDictionary dictionary];
////    [params setObject:@"NewFile" forKey:@"attachmentType"];
////    if (name) [params setObject:name forKey:TITLE];
////    if (description) [params setObject:description forKey:@"description"];
////    [params setObject:@"body text" forKey:@"text"];
////    
////    NSMutableDictionary *attachmentParams = [NSMutableDictionary dictionary];
////    [attachmentParams setObject:params forKey:@"attachment"];
//    
//    NSData *jsonNSData = [NSData dataWithContentsOfFile:@"/Users/rraodv/apps/instaforce/fdata.json"];
//    NSError *error = nil;
//    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonNSData options:kNilOptions error:&error];
//    
//    
//    
//    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:dictionary];
//    NSLog(@"%@", dictionary);
//    [request addPostFileData:data paramName:FILE_DATA fileName:name mimeType:mimeType];
//    
//    NSLog(@"%@", request);
//    return request;
//}

- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


#pragma mark - segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"ShowFilterViewSegue"]) {
        [[segue destinationViewController] setOriginalImage:self.image] ;
    }
}








@end
