//
//  IconDownloader.m
//  instaforce
//
//   This is a modified version of IconDownloader.m from Apple's LazyTable example
//
//  Created by Raja Rao DV on 2/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//
#import "IconDownloader.h"
#import "FeedItem.h"

#define imageSize 48

@interface IconDownloader ()
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@end


@implementation IconDownloader

#pragma mark

- (void)startDownloadWithURL:(NSString *) imageURL AndToken:(NSString *) sessionToken
{
    self.activeDownload = [NSMutableData data];
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.feedItem.ownerProfileURLString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    
    NSString *token = [@"OAuth " stringByAppendingString:sessionToken];
    
    [request setValue:token forHTTPHeaderField:@"Authorization"];

    
    // alloc+init and start an NSURLConnection; release on completion/failure
   // NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //async connection!!
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self
                                   startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSRunLoopCommonModes];
    [connection start];

    self.imageConnection = connection;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    //release active download
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
    if (self.completionHandler)
        self.completionHandler(image);
}

@end

