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


#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceNativeSDK/SFRestAPI+Blocks.h>
#import <SalesforceNativeSDK/SFRestAPI+Files.h>
#import <SalesforceNativeSDK/SFRestRequest.h>

typedef void (^ThumbnailLoadedBlock) (UIImage *thumbnailImage);

@interface FeedsViewController () {
    
    
}

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) NSMutableDictionary *attachmentDownloadsInProgress;



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



#pragma mark Misc

- (void)didReceiveMemoryWarning
{
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

- (void)dealloc
{
    self.feedItems = nil;
    self.logoutButton = nil;
    self.cancelRequestsButton = nil;
    self.ownedFilesButton = nil;
    self.sharedFilesButton = nil;
    self.groupsFilesButton = nil;
    self.thumbnailCache = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad {
    self.token = [SFRestAPI  sharedInstance].coordinator.credentials.accessToken;
    
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
    
    self.feedItems = [[NSMutableArray alloc] init];
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

    
    SFRestAPI *api = [SFRestAPI sharedInstance];
    
    
    NSString *path =  [NSString stringWithFormat:@"/%@/chatter/feeds/news/me/feed-items", [api apiVersion]];
    
    SFRestRequest* request =  [SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
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
    NSLog(@"%@", jsonResponse);
    
    NSArray *feedsJsonObj = jsonResponse[@"items"];
    NSLog(@"request:didLoadResponse: #files: %d", feedsJsonObj.count);

    for (int i =0; i < feedsJsonObj.count; i++) {
        NSDictionary *feedObj = feedsJsonObj[i];
        if(feedObj[@"attachment"] != [NSNull null]) {
            FeedItem *feedItem = [[FeedItem alloc] initWithJsonObj:feedObj];
            NSLog(@"%@", feedItem);
            [self.feedItems addObject:feedItem];
        }
    }
    NSLog(@"self.feedItems count %ui", [self.feedItems count]);
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
    
    //remove placeholder texts set by storyboard (useful in storyboard, but not here)
    cell.Owner.text =  @"";
    cell.likesCount.text = @"";
    
	// Configure the cell to show the data.
    FeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.row];

    NSString *photoId = feedItem.attachmentId;
    NSLog(@"%@", photoId);
  //  NSInteger tag = [photoId hash];
  
    //if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
        [self loadImagesForOnscreenRows];
    //}

		
//        // Only load cached images; defer new downloads until scrolling ends
//        if (!feedItem.ownerProfileIcon)
//        {
//            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
//            {
//                [self startIconDownload:appRecord forIndexPath:indexPath];
//            }
//            // if a download is deferred or in progress, return a placeholder image
//            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
//        }
//        else
//        {
//            cell.imageView.image = appRecord.appIcon;
//        }
    
    
    
//    NSDictionary *photo = obj[@"parent"][@"photo"];
//    NSString *token = [SFRestAPI  sharedInstance].coordinator.credentials.accessToken;
//    NSString *profilePicUrl = [NSString stringWithFormat:@"%@%@%@", [photo  objectForKey:@"smallPhotoUrl"], @"?oauth_token=", token];
//    NSURL * imageURL = [NSURL URLWithString:profilePicUrl];
//    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
//    UIImage * image = [UIImage imageWithData:imageData];
//    cell.ownerImageView.image = image;
    
//	cell.textLabel.text =  obj[@"title"];
//    cell.detailTextLabel.text = obj[@"owner"][@"name"];
    
    
//    cell.tag = tag;
//    [self getThumbnail:photoId completeBlock:^(UIImage* thumbnailImage) {
//        // Cell are recycled - we don't want to set the image if the cell is showing a different file
//        if (cell.tag == tag) {
//            //cell.imageView.image = thumbnailImage;
//            cell.Owner.text = feedItem.ownerName;
//            cell.likesCount.text = feedItem.likesCount;
//            cell.myImageView.image = thumbnailImage;
//        }
//    }];
    
	return cell;
    
}

#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(FeedItem *)feedItem forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.feedItem = feedItem;
        [iconDownloader setCompletionHandler:^(UIImage *image){
            
            CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            //cell.ownerImageView.image = feedItem.ownerProfileIcon;
            feedItem.ownerPhotoImageCache = image;
            cell.ownerImageView.image = image;
            //cell.myImageView.image = image;
            //feedItem.photoAttachmentImage = image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        
        [iconDownloader startDownloadWithURL:feedItem.ownerProfileURLString AndToken:self.token];
    }
    
    
}

// -------------------------------------------------------------------------------
//	startPhotoAttachmentDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startAttachmentDownload:(FeedItem *)feedItem forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.attachmentDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.feedItem = feedItem;
        [iconDownloader setCompletionHandler:^(UIImage *image){
            
            CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            //cell.ownerImageView.image = feedItem.ownerProfileIcon;
            // cell.ownerImageView.image = image;
            feedItem.mainPhotoAttachmentCache = image;
            cell.myImageView.image = image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.attachmentDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.attachmentDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        //[iconDownloader startDownload];
        
        [iconDownloader startDownloadWithURL:feedItem.photoAttachmentURLString AndToken:self.token];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([self.feedItems count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
       // NSIndexPath *lastIndexPath = [visiblePaths lastObject];
        
        for (NSIndexPath *indexPath in visiblePaths)
        {
            FeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.row];
            NSLog(@"***** load for indexpath: %d", indexPath.row);
            
            [self loadImageForFeedItem:feedItem forIndexPath:indexPath];
            [self loadPhotoAttachmentForFeedItem:feedItem forIndexPath:indexPath];
        }
        
//        if((lastIndexPath.row + 1) < [self.feedItems count]) {
//            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:(lastIndexPath.row + 1) inSection:1];
//            FeedItem *feedItem = [self.feedItems objectAtIndex:(lastIndexPath.row + 1)];
//            [self loadImageForFeedItem:feedItem forIndexPath: nextIndexPath];
//        }
    }
}

-(void) loadImageForFeedItem:(FeedItem *) feedItem forIndexPath:(NSIndexPath *) indexPath
{
    if(feedItem == nil) {
        return;
    }
    
    if (!feedItem.ownerPhotoImageCache)
        // Avoid the app icon download if the app already has an icon
    {
        NSLog(@"***** ownerPhotoImageCache not found: %d", indexPath.row);

        [self startIconDownload:feedItem forIndexPath:indexPath];
    } else {
        NSLog(@"***** ownerPhotoImageCache found: %d", indexPath.row);
        CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.ownerImageView.image = feedItem.ownerPhotoImageCache;
    }
}

-(void) loadPhotoAttachmentForFeedItem:(FeedItem *) feedItem forIndexPath:(NSIndexPath *) indexPath
{
    if(feedItem == nil) {
        return;
    }
    
    if (!feedItem.mainPhotoAttachmentCache)
        // Avoid the app icon download if the app already has an icon
    {
        NSLog(@"***** mainPhotoAttachmentCache not found: %d", indexPath.row);
        
        [self startAttachmentDownload:feedItem forIndexPath:indexPath];
    } else {
        NSLog(@"***** mainPhotoAttachmentCache found: %d", indexPath.row);
        CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.myImageView.image = feedItem.mainPhotoAttachmentCache;
    }
}

#pragma mark - UIScrollViewDelegate
//
//// -------------------------------------------------------------------------------
////	scrollViewDidEndDragging:willDecelerate:
////  Load images for all onscreen rows when scrolling is finished.
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate)
//	{
//        [self loadImagesForOnscreenRows];
//    }
//}
//
//// -------------------------------------------------------------------------------
////	scrollViewDidEndDecelerating:
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    [self loadImagesForOnscreenRows];
//}



@end
