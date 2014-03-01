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

#import "FeedItem.h"
#import "IconDownloader.h"
#import "SettingsViewController.h"


#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceNativeSDK/SFRestAPI+Blocks.h>
//#import <SalesforceNativeSDK/SFRestAPI+Files.h>
#import <SalesforceNativeSDK/SFRestRequest.h>

typedef void (^ThumbnailLoadedBlock)(UIImage *thumbnailImage);

@interface FeedsViewController () {


}

@property(nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic, strong) NSMutableDictionary *attachmentDownloadsInProgress;
@property(nonatomic, strong) NSString *selectedGroupIdFromSettings;


- (void)loadFeedItemsFromChatter;


@end

@implementation FeedsViewController



#pragma mark Misc

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [self.imageDownloadsInProgress removeAllObjects];

    NSArray *allAttachmentDownloads = [self.attachmentDownloadsInProgress allValues];
    [allAttachmentDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [self.attachmentDownloadsInProgress removeAllObjects];
}

- (void)dealloc {
    self.feedItems = nil;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.token = [SFRestAPI sharedInstance].coordinator.credentials.accessToken;


    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCellXIB"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"customTableCellSBID"];
    
    //allocate
    self.feedItems = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //get group id from settings tab (index 2)
    SettingsViewController *svc = [[self.tabBarController viewControllers] objectAtIndex: 2];
    self.selectedGroupIdFromSettings = svc.selectedGroupId;
    
    [self loadFeedItemsFromChatter];
}

//Used to scroll to top once the feed is displayed.
//Useful to show new photo at the top after it was posted
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}


#pragma mark - Chatter Related

- (void)loadFeedItemsFromChatter {
    SFRestAPI *api = [SFRestAPI sharedInstance];

    NSString *path;
    if(self.selectedGroupIdFromSettings) { //get feed from group
       path = [NSString stringWithFormat:@"/%@/chatter/feeds/record/%@/feed-items", [api apiVersion], self.selectedGroupIdFromSettings];
   
    } else {// get feed from current user's main news feed (default)
        path = [NSString stringWithFormat:@"/%@/chatter/feeds/news/me/feed-items", [api apiVersion]];

    }

    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}


#pragma mark - Table view data source

//deselect highlighting / selection of row
- (void)tableView:(UITableView *)tblView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tblView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"customTableCellSBID";

    // Dequeue or create a cell of the appropriate type.
    CustomTableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    //add current controller as delegate to cell's LikesButton control
    cell.delegate = self;

    FeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.row];

    cell.Owner.text = feedItem.ownerName;
    [cell.likeBtnLabel setTitle:feedItem.likesCount forState:UIControlStateNormal];
    
    
    //load or add-from-cache profile photo
    if(feedItem.ownerPhotoImageCache) {
        cell.ownerImageView.image = feedItem.ownerPhotoImageCache;
    } else {
        [self startIconDownload:feedItem forIndexPath:indexPath];
    }
    
    //load or add-from-cache photo attachment
    if(feedItem.mainPhotoAttachmentCache) {
         cell.myImageView.image = feedItem.mainPhotoAttachmentCache;
        
        cell.myImageView.alpha = 0.0;
        [UIView animateWithDuration:0.5
                         animations:^{
                             cell.myImageView.alpha = 1.0;
                         }];
    } else {
        [self startAttachmentDownload:feedItem forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - likeButtonDelegateHandler

- (void) likeButtonClickedOnCell:(id)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    FeedItem *feed = [self.feedItems objectAtIndex:indexPath.row];
    if(feed.myLike  != (id)[NSNull null]) {
        //todo add unlike code here
        return;
    }
    int newLikesCount = [feed.likesCount intValue]+ 1;
    
    feed.likesCount = [NSString stringWithFormat:@"%d", newLikesCount];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    
    //HTTP POST na15.salesforce.com/services/data/v29.0/chatter/feed-items/0D5i000000RL7FOCA1/likes
    
    SFRestAPI *api = [SFRestAPI sharedInstance];
    
    NSString *path = [NSString stringWithFormat:@"/%@/chatter/feed-items/%@/likes", [api apiVersion], feed.feedId];
    
    
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:nil];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(FeedItem *)feedItem forIndexPath:(NSIndexPath *)indexPath {
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.feedItem = feedItem;
        [iconDownloader setCompletionHandler:^(UIImage *image) {

            CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];

            // Display the newly loaded image
            feedItem.ownerPhotoImageCache = image;
            cell.ownerImageView.image = image;


            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];

        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];

        [iconDownloader startDownloadWithURL:feedItem.ownerProfileURLString AndToken:self.token];
    }
}

// -------------------------------------------------------------------------------
//	startAttachmentDownload:forIndexPath:
//  Use Salesforce iOS SDK's 'requestForFileContents:' to download image files
// -------------------------------------------------------------------------------

- (void)startAttachmentDownload:(FeedItem *)feedItem forIndexPath:(NSIndexPath *)indexPath {
    
    //Create image request for attachment id.
    SFRestRequest *imageRequest = [[SFRestAPI sharedInstance] requestForFileContents:feedItem.attachmentId version:nil];
    
    //Load images asynchronously. 'completeBlock' is called when image data is downloaded.
    [[SFRestAPI sharedInstance] sendRESTRequest:imageRequest failBlock:nil completeBlock:^(NSData *responseData) {
        NSLog(@"downloadThumbnail:%@ completed", feedItem.attachmentId);
        UIImage *image = [UIImage imageWithData:responseData];
        CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        
        //Grab main thread to display image asynchronously
        dispatch_async(dispatch_get_main_queue(), ^{
            //cache loaded image
            feedItem.mainPhotoAttachmentCache = image;
            //set image to cell
            cell.myImageView.image = image;
            
            //animate fade in
            cell.myImageView.alpha = 0.0;
            [UIView animateWithDuration:0.5
                             animations:^{
                                 cell.myImageView.alpha = 1.0;
                             }];        });
    }];

}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    
    NSRange range = [request.path rangeOfString:@"/likes"];
    
    //dont do anything if it was likes
    if (range.location == NSNotFound) {
        
        //important to remove all feedItems before adding them back in.
        [self.feedItems removeAllObjects];
        
        NSArray *feedsJsonObj = jsonResponse[@"items"];
        for (int i = 0; i < feedsJsonObj.count; i++) {
            NSDictionary *feedObj = feedsJsonObj[i];
            NSDictionary *attachment = feedObj[@"attachment"];
            if (attachment != (id)[NSNull null] && [[attachment objectForKey:@"mimeType"] isEqualToString:@"image/jpeg"]) {
                FeedItem *feedItem = [[FeedItem alloc] initWithJsonObj:feedObj];
                [self.feedItems addObject:feedItem];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
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
