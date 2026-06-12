#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LirauGlobalCitizenLorauaProfile : NSObject

@property (nonatomic, copy) NSString *globalCitizenLorauaID;
@property (nonatomic, copy) NSString *emailMarketingLorauaAddress;
@property (nonatomic, copy) NSString *nativeSpeakerLorauaName;
@property (nonatomic, copy) NSString *profileIntroLorauaBio;
@property (nonatomic, copy) NSString *languagePairingLorauaSummary;
@property (nonatomic, copy) NSString *avatarChatLorauaURLString;
@property (nonatomic, copy) NSString *virtualCurrencyLorauaBalance;
@property (nonatomic, assign) NSInteger peerLearningLorauaFollowingCount;
@property (nonatomic, assign) NSInteger narrativeSharingLorauaPostCount;
@property (nonatomic, assign) NSInteger globalCommunityLorauaFollowersCount;

+ (instancetype)globalCitizenLorauaLocalProfileWithDictionary:(NSDictionary *)dictionary emailMarketingLorauaAddress:(NSString *)emailMarketingLorauaAddress;
+ (instancetype)globalCitizenLorauaTestProfile;
- (void)mergeGlobalCitizenLorauaRemoteDictionary:(NSDictionary *)dictionary;

@end

@interface LirauNarrativeSharingLorauaPost : NSObject

@property (nonatomic, copy) NSString *postID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *authorAvatarURLString;
@property (nonatomic, copy) NSString *coverURLString;
@property (nonatomic, copy) NSString *videoCoverURLString;
@property (nonatomic, assign) BOOL hasVideo;

+ (instancetype)narrativeSharingLorauaPostWithDictionary:(NSDictionary *)dictionary fallbackAuthor:(NSString *)fallbackAuthor;
+ (instancetype)mockNarrativeSharingLorauaPostWithTitle:(NSString *)title authorName:(NSString *)authorName;

@end

@interface LirauProfileIntroLorauaContent : NSObject

@property (nonatomic, strong) LirauGlobalCitizenLorauaProfile *globalCitizenLorauaProfile;
@property (nonatomic, copy) NSArray<LirauNarrativeSharingLorauaPost *> *posts;

+ (instancetype)mockDiscoveryFeedLorauaContent;

@end

NS_ASSUME_NONNULL_END
