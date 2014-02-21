//
//  FeedItem.h
//  This class creates a simplified version of a Chatter Feed Item
//
//  Created by Raja Rao DV on 2/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//
#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceNativeSDK/SFRestAPI.h>


@interface FeedItem : NSObject

@property(nonatomic, strong) NSString *attachmentId;
@property(nonatomic, strong) UIImage *ownerPhotoImageCache;
@property(nonatomic, strong) UIImage *mainPhotoAttachmentCache;
@property(nonatomic, strong) NSString *ownerProfileURLString;
@property(nonatomic, strong) NSString *photoAttachmentURLString;
@property(nonatomic, strong) NSString *ownerName;
@property(nonatomic, strong) NSString *likesCount;
@property(nonatomic, strong) NSString *commentsCount;
@property(nonatomic, strong) NSString *feedId;
@property(nonatomic, strong) NSDictionary *raw;


- (id)initWithJsonObj:(NSDictionary *)jsonObj;

@end

