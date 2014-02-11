//
//  FeedsViewController.m
//  instaforce
//
//  Created by Raja Rao DV on 2/7/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "FeedsViewController.h"
#import "SFRestAPI.h"
#import "SFRestAPI+Files.h"
#import "SFRestRequest.h"


#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceNativeSDK/SFRestAPI+Blocks.h>
#import <SalesforceNativeSDK/SFRestAPI+Files.h>
#import <SalesforceNativeSDK/SFRestRequest.h>

typedef void (^ThumbnailLoadedBlock) (UIImage *thumbnailImage);

@interface FeedsViewController () {
    
}

@property (nonatomic, strong) UIBarButtonItem* logoutButton;
@property (nonatomic, strong) UIBarButtonItem* cancelRequestsButton;
@property (nonatomic, strong) UIBarButtonItem* ownedFilesButton;
@property (nonatomic, strong) UIBarButtonItem* sharedFilesButton;
@property (nonatomic, strong) UIBarButtonItem* groupsFilesButton;
// very basic in-memory cache
@property (nonatomic, strong) NSMutableDictionary* thumbnailCache;

- (void) downloadThumbnail:(NSString*)fileId completeBlock:(ThumbnailLoadedBlock)completeBlock;
- (void) logout;
- (void) cancelRequests;
- (void) showOwnedFiles;
- (void) showGroupsFiles;
- (void) showSharedFiles;

@end

@implementation FeedsViewController

@synthesize dataRows;
@synthesize logoutButton;
@synthesize cancelRequestsButton;
@synthesize ownedFilesButton;
@synthesize sharedFilesButton;
@synthesize groupsFilesButton;

#pragma mark Misc

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.dataRows = nil;
    self.logoutButton = nil;
    self.cancelRequestsButton = nil;
    self.ownedFilesButton = nil;
    self.sharedFilesButton = nil;
    self.groupsFilesButton = nil;
    self.thumbnailCache = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad {
    self.thumbnailCache = [NSMutableDictionary dictionary];
    // self.title = @"FileExplorer";
  
    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCellXIB"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"customTableCellSBID"];
}

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCellXIB"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"customTableCellSBID"];
    
      [self showOwnedFiles];
}

//- (void)loadView {
//    [super loadView];
//    self.thumbnailCache = [NSMutableDictionary dictionary];
//   // self.title = @"FileExplorer";
//    [self showOwnedFiles];
//}

#pragma mark - Button handlers

- (void) logout
{
    [[SFAuthenticationManager sharedManager] logout];
}

-(void) cancelRequests
{
    [[SFRestAPI sharedInstance] cancelAllRequests];
}

- (void) showOwnedFiles
{
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForOwnedFilesList:nil page:0];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void) showGroupsFiles
{
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForFilesInUsersGroups:nil page:0];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void) showSharedFiles
{
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForFilesSharedWithUser:nil page:0];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}


#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSArray *files = jsonResponse[@"files"];
    NSLog(@"request:didLoadResponse: #files: %d", files.count);
    self.dataRows = files;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


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

#pragma mark - thumbnail handling

/**
 * Return image from cache if available, otherwise download image from server, and then size it and cache it
 */
- (void) getThumbnail:(NSString*) fileId completeBlock:(ThumbnailLoadedBlock)completeBlock {
    // cache hit
    if (self.thumbnailCache[fileId]) {
        completeBlock(self.thumbnailCache[fileId]);
    }
    // cache miss
    else {
        [self downloadThumbnail:fileId completeBlock:^(UIImage *image) {
//            // size it
//            UIGraphicsBeginImageContext(CGSizeMake(720,480));
//            [image drawInRect:CGRectMake(0, 0, image.size.width, 480)];
//            UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
            // cache it
           // self.thumbnailCache[fileId] = thumbnailImage;
            // done
           // completeBlock(thumbnailImage);
            completeBlock(image);
        }];
    }
}

- (void) downloadThumbnail:(NSString*)fileId completeBlock:(ThumbnailLoadedBlock)completeBlock {
    //  SFRestRequest *imageRequest = [[SFRestAPI sharedInstance] requestForFileRendition:fileId version:nil renditionType:@"THUMB720BY480" page:0];
    SFRestRequest *imageRequest = [[SFRestAPI sharedInstance] requestForFileContents:fileId version:nil];
    
    [[SFRestAPI sharedInstance] sendRESTRequest:imageRequest failBlock:nil completeBlock:^(NSData *responseData) {
        NSLog(@"downloadThumbnail:%@ completed", fileId);
        UIImage *image = [UIImage imageWithData:responseData];
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(image);
        });
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"customTableCellSBID";
    
    // Dequeue or create a cell of the appropriate type.
    CustomTableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
	// Configure the cell to show the data.
    NSDictionary *obj = [dataRows objectAtIndex:indexPath.row];
    NSString *fileId = obj[@"id"];
    NSInteger tag = [fileId hash];
    
//	cell.textLabel.text =  obj[@"title"];
//    cell.detailTextLabel.text = obj[@"owner"][@"name"];
    cell.tag = tag;
    [self getThumbnail:fileId completeBlock:^(UIImage* thumbnailImage) {
        // Cell are recycled - we don't want to set the image if the cell is showing a different file
        if (cell.tag == tag) {
            //cell.imageView.image = thumbnailImage;
            cell.fileName.text = obj[@"title"];
            cell.ownerName.text = obj[@"owner"][@"name"];
            cell.myImageView.image = thumbnailImage;
            [cell setNeedsLayout];
        }
    }];
    
	return cell;
    
}


@end
