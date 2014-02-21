//
//  IconDownloader.h
//  instaforce
//
//   This is a modified version of IconDownloader.m from Apple's LazyTable example.This helps asynchronously download images
//   and icons.
//
//  Created by Raja Rao DV on 2/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

@class FeedItem;


@interface IconDownloader : NSObject

@property(nonatomic, strong) FeedItem *feedItem;
@property(nonatomic, copy) void (^completionHandler)(UIImage *);

- (void)startDownloadWithURL:(NSString *)imageURL AndToken:(NSString *)sessionToken;

- (void)cancelDownload;

@end
