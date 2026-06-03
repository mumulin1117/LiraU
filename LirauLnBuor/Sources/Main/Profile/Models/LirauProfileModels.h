#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LirauProfileUser : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *profileIntroLoraua;
@property (nonatomic, copy) NSString *languagePairingLoraua;
@property (nonatomic, copy) NSString *avatarURLString;
@property (nonatomic, copy) NSString *walletBalance;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) NSInteger postCount;
@property (nonatomic, assign) NSInteger followersCount;

+ (instancetype)localUserWithDictionary:(NSDictionary *)dictionary email:(NSString *)email;
+ (instancetype)testUser;
- (void)mergeRemoteDictionary:(NSDictionary *)dictionary;

@end

@interface LirauProfilePost : NSObject

@property (nonatomic, copy) NSString *postID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *authorAvatarURLString;
@property (nonatomic, copy) NSString *coverURLString;
@property (nonatomic, copy) NSString *videoCoverURLString;
@property (nonatomic, assign) BOOL hasVideo;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary fallbackAuthor:(NSString *)fallbackAuthor;
+ (instancetype)mockWithTitle:(NSString *)title authorName:(NSString *)authorName;

@end

@interface LirauProfileContent : NSObject

@property (nonatomic, strong) LirauProfileUser *user;
@property (nonatomic, copy) NSArray<LirauProfilePost *> *posts;

+ (instancetype)mockContent;

@end

NS_ASSUME_NONNULL_END
