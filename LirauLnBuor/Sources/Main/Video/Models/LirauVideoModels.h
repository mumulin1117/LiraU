#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LirauVideoCategory) {
    LirauVideoCategoryHot = 0,
    LirauVideoCategoryWow = 1
};

@interface LirauVideoItem : NSObject

@property (nonatomic, copy) NSString *dynamicId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatarURLString;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *videoCoverURLString;
@property (nonatomic, copy) NSString *fallbackImageURLString;
@property (nonatomic, assign) NSInteger likeCount;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger storeCount;
@property (nonatomic, assign) NSInteger forwardCount;
@property (nonatomic, assign) BOOL likedLocally;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)mockWithTitle:(NSString *)title userName:(NSString *)userName;
- (NSString *)displayCoverURLString;
- (NSString *)displayDescription;

@end

NS_ASSUME_NONNULL_END
