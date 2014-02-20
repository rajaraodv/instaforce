#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceNativeSDK/SFRestAPI.h>


@interface FeedItem : NSObject

@property (nonatomic, strong) NSString *attachmentId;
@property (nonatomic, strong) UIImage *ownerPhotoImageCache;
@property (nonatomic, strong) UIImage *mainPhotoAttachmentCache;
@property (nonatomic, strong) NSString *ownerProfileURLString;
@property (nonatomic, strong) NSString *photoAttachmentURLString;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *likesCount;
@property (nonatomic, strong) NSString *commentsCount;
@property (nonatomic, strong) NSDictionary *raw;




- (id)initWithJsonObj:(NSDictionary *)jsonObj;

@end

