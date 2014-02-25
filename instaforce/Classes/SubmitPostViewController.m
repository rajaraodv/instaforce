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

#import "SettingsViewController.h"

@interface SubmitPostViewController ()
@property (atomic, strong) NSString* selectedGroupIdFromSettings;
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
    self.addPostTextField.layer.masksToBounds=YES;
    self.addPostTextField.layer.borderColor=[[UIColor grayColor]CGColor];
    self.addPostTextField.layer.borderWidth= 1.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Get tabBarController and get settings tab (index 2) and then get currently selectd group id.
    UITabBarController *tbc = (UITabBarController *)self.presentingViewController.presentingViewController;
    SettingsViewController *svc = [[tbc viewControllers] objectAtIndex:2];
    self.selectedGroupIdFromSettings = svc.selectedGroupId;
    
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
                                                                         name:@"fileFromInstaForce.jpeg"
                                                                  description:@"Photo From Instaforce App"
                                                                     mimeType:@"image/jpeg"];


    [[SFRestAPI sharedInstance] send:request delegate:self];
    
}

- (void)createFeedForAttachmentId:(NSString *)attachmentId {
//Load json template from "feedTemplate.json" file as a string. Then replace __BODY_TEXT__ and __ATTACHMENT_ID__ w/
// addPostTextField.text and attachmentId and pass that to post to chatter feed.
//    {
//        "body": {
//            "messageSegments": [
//                                {
//                                    "type": "Text",
//                                    "text": "__BODY_TEXT__"
//                                }
//                                ]
//        },
//        "attachment": {
//            "attachmentType": "ExistingContent",
//            "contentDocumentId": "__ATTACHMENT_ID__"
//        }
//    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"feedTemplate" ofType:@"json"];
    NSError *error = nil;
    NSData *feedJSONTemplateData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    
    NSString* feedJSONTemplateStr = [[NSString alloc] initWithData:feedJSONTemplateData encoding:NSUTF8StringEncoding];
    feedJSONTemplateStr = [feedJSONTemplateStr stringByReplacingOccurrencesOfString:@"__BODY_TEXT__" withString:self.addPostTextField.text];
    feedJSONTemplateStr = [feedJSONTemplateStr stringByReplacingOccurrencesOfString:@"__ATTACHMENT_ID__" withString:attachmentId];
    
    
    NSDictionary *jsonObj =
    [NSJSONSerialization JSONObjectWithData: [feedJSONTemplateStr dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &error];
    

    SFRestAPI *api = [SFRestAPI sharedInstance];

    NSString *path;
    if(self.selectedGroupIdFromSettings) { // post to user selected group
        path = [NSString stringWithFormat:@"/%@/chatter/feeds/record/%@/feed-items/", [api apiVersion],  self.selectedGroupIdFromSettings];
    } else { // post to user's main feed
       path = [NSString stringWithFormat:@"/%@/chatter/feeds/user-profile/me/feed-items", [api apiVersion]];
    }
   
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:jsonObj];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - salesforce rest delegates

- (void)request:(SFRestRequest *)request didLoadResponse:(id)dataResponse {

    NSString *attachmentId = [dataResponse objectForKey:@"id"];

    NSRange range = [request.path rangeOfString:@"/feed-items"];

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
