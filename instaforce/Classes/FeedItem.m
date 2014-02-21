#import "FeedItem.h"

@implementation FeedItem


- (id)initWithJsonObj:(NSDictionary *)jsonObj {
    self = [super init];


    NSDictionary *photo = jsonObj[@"parent"][@"photo"];
    NSString *token = [SFRestAPI sharedInstance].coordinator.credentials.accessToken;
    NSString *instanceUrl = (NSString *) [SFRestAPI sharedInstance].coordinator.credentials.instanceUrl;

    self.ownerProfileURLString = [NSString stringWithFormat:@"%@%@%@", [photo objectForKey:@"smallPhotoUrl"], @"?oauth_token=", token];

    self.photoAttachmentURLString = [NSString stringWithFormat:@"%@%@%@", instanceUrl, jsonObj[@"attachment"][@"renditionUrl"], @"?type=THUMB720BY480"];

    self.attachmentId = jsonObj[@"attachment"][@"id"];
    self.ownerName = jsonObj[@"parent"][@"name"];
    self.likesCount = [jsonObj[@"likes"][@"total"] description];
    self.commentsCount = [jsonObj[@"comments"][@"total"] description];
    self.raw = jsonObj;

    return self;
};

@end

