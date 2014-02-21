//
//  SubmitPostViewController.m
//  instaforce
//
//  Created by Raja Rao DV on 2/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SubmitPostViewController.h"
#import "SFRestAPI.h"
#import "SFRestAPI+Files.h"
#import "SFRestRequest.h"

@interface SubmitPostViewController ()

@end

@implementation SubmitPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.modifiedImageView.image = self.modifiedImage;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - buttons
- (IBAction)cancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitBtn:(id)sender {
    [self uploadImageToSalesforce];
}

#pragma mark - salesforce
- (void)uploadImageToSalesforce {

    NSLog(@"Doing upload");

    NSData *data = UIImageJPEGRepresentation(self.modifiedImage, 0.5);
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUploadFile:data
                                                                         name:@"filteredFile.jpeg"
                                                                  description:@"Filtered File"
                                                                     mimeType:@"image/jpeg"];


    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)createFeedForAttachmentId:(NSString *)attachmentId {
    //    { "attachment":
    //        {
    //            "attachmentType":"ExistingContent",
    //            "contentDocumentId": "069i00000017Do3AAE"
    //        }
    //    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"ExistingContent" forKey:@"attachmentType"];
    [params setObject:attachmentId forKey:@"contentDocumentId"];

    NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];
    [jsonObj setObject:params forKey:@"attachment"];

    SFRestAPI *api = [SFRestAPI sharedInstance];


    NSString *path = [NSString stringWithFormat:@"/%@/chatter/feeds/user-profile/me/feed-items", [api apiVersion]];

    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:jsonObj];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - salesforce rest delegates

- (void)request:(SFRestRequest *)request didLoadResponse:(id)dataResponse {

    NSString *attachmentId = [dataResponse objectForKey:@"id"];

    NSRange range = [request.path rangeOfString:@"/me/feed-items"];

    //Note: this request:didLoadResponse is called for both Attachment upload and create feedItem.
    //So we need to distinguish b/w the two and take appropriate action
    if (range.location == NSNotFound) {
        //Just uploaded image but not associated it to a feed item, so create feedItem w/ attachment.
        [self createFeedForAttachmentId:attachmentId];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)request:(SFRestRequest *)request didFailLoadWithError:(NSError *)error {
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

@end
