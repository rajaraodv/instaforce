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

typedef void (^ThumbnailLoadedBlock)(UIImage *thumbnailImage);

@interface FeedsViewController () {


}

@property(nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic, strong) NSMutableDictionary *attachmentDownloadsInProgress;


@property(nonatomic, strong) UIBarButtonItem *logoutButton;
@property(nonatomic, strong) UIBarButtonItem *cancelRequestsButton;
@property(nonatomic, strong) UIBarButtonItem *ownedFilesButton;
@property(nonatomic, strong) UIBarButtonItem *sharedFilesButton;
@property(nonatomic, strong) UIBarButtonItem *groupsFilesButton;
// very basic in-memory cache
@property(nonatomic, strong) NSMutableDictionary *thumbnailCache;


- (void)logout;

- (void)cancelRequests;

- (void)loadFeedItemsFromChatter;

- (void)showGroupsFiles;

- (void)showSharedFiles;

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
    self.logoutButton = nil;
    self.cancelRequestsButton = nil;
    self.ownedFilesButton = nil;
    self.sharedFilesButton = nil;
    self.groupsFilesButton = nil;
    self.thumbnailCache = nil;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.token = [SFRestAPI sharedInstance].coordinator.credentials.accessToken;

    self.thumbnailCache = [NSMutableDictionary dictionary];
    // self.title = @"FileExplorer";

    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCellXIB"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"customTableCellSBID"];
    
    
    self.feedItems = [[NSMutableArray alloc] init];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadFeedItemsFromChatter];
}

//Used to scroll to top once the feed is displayed.
//Useful to show new photo at the top after it was posted
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}


#pragma mark - Button handlers

- (void)logout {
    [[SFAuthenticationManager sharedManager] logout];
}

- (void)cancelRequests {
    [[SFRestAPI sharedInstance] cancelAllRequests];
}

- (void)loadFeedItemsFromChatter {


    SFRestAPI *api = [SFRestAPI sharedInstance];


    NSString *path = [NSString stringWithFormat:@"/%@/chatter/feeds/news/me/feed-items", [api apiVersion]];

    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)showGroupsFiles {
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForFilesInUsersGroups:nil page:0];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)showSharedFiles {
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForFilesSharedWithUser:nil page:0];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}


#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
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


    FeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.row];

    cell.Owner.text = feedItem.ownerName;
    cell.likesCount.text = feedItem.likesCount;
    
    //load or add-from-cache profile photo
    if(feedItem.ownerPhotoImageCache) {
        cell.ownerImageView.image = feedItem.ownerPhotoImageCache;
    } else {
        [self startIconDownload:feedItem forIndexPath:indexPath];
    }
    
    //load or add-from-cache photo attachment
    if(feedItem.mainPhotoAttachmentCache) {
         cell.myImageView.image = feedItem.mainPhotoAttachmentCache;
    } else {
        [self startAttachmentDownload:feedItem forIndexPath:indexPath];
    }

    return cell;
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
//	startPhotoAttachmentDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startAttachmentDownload:(FeedItem *)feedItem forIndexPath:(NSIndexPath *)indexPath {
    IconDownloader *iconDownloader = [self.attachmentDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.feedItem = feedItem;
        [iconDownloader setCompletionHandler:^(UIImage *image) {

            CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];

            // Display the newly loaded image
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


//
//- (void)loadImageForFeedItem:(FeedItem *)feedItem forIndexPath:(NSIndexPath *)indexPath {
//    if (feedItem == nil) {
//        return;
//    }
//
//    if (!feedItem.ownerPhotoImageCache)
//            // Avoid the app icon download if the app already has an icon
//    {
//        [self startIconDownload:feedItem forIndexPath:indexPath];
//    } else {
//        @try {
//            // at times this throws NSRangeException exception
//            CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
//            cell.ownerImageView.image = feedItem.ownerPhotoImageCache;
//        }
//        @catch (NSException *e) {
//            //ignore
//           // NSLog(@"Exception trying to set image from cache: %@", e);
//        }
//    }
//}

//- (void)loadPhotoAttachmentForFeedItem:(FeedItem *)feedItem forIndexPath:(NSIndexPath *)indexPath {
//    if (feedItem == nil) {
//        return;
//    }
//
//    if (!feedItem.mainPhotoAttachmentCache)
//            // Avoid the app icon download if the app already has an icon
//    {
//        [self startAttachmentDownload:feedItem forIndexPath:indexPath];
//    } else {
//        @try {
//            CustomTableViewCell *cell = (CustomTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
//            cell.myImageView.image = feedItem.mainPhotoAttachmentCache;
//        }
//        @catch (NSException *exception) {
//            //ignore
//        }
//    }
//}


@end
