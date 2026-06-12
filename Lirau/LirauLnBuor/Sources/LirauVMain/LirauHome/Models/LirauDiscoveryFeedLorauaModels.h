#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LirauTandemLearningLorauaRecommendation : NSObject

@property (nonatomic, copy) NSString *languageExchangePartnerLorauaID;
@property (nonatomic, copy) NSString *nativeSpeakerLorauaName;
@property (nonatomic, copy) NSString *avatarChatLorauaURLString;
@property (nonatomic, copy) NSString *conversationStarterLorauaBrief;

+ (instancetype)discoveryFeedLorauaModelWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)mockTandemLearningLorauaRecommendationWithName:(NSString *)nativeSpeakerLorauaName conversationStarterLorauaBrief:(NSString *)conversationStarterLorauaBrief;

@end

@interface LirauNarrativeSharingLorauaDynamicItem : NSObject

@property (nonatomic, copy) NSString *dynamicId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imageURLString;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatarURLString;
@property (nonatomic, assign) NSInteger praiseCount;
@property (nonatomic, assign) NSInteger storeCount;
@property (nonatomic, assign) NSInteger commentCount;

+ (instancetype)discoveryFeedLorauaModelWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)mockNarrativeSharingLorauaDynamicWithTitle:(NSString *)title content:(NSString *)content;

@end

@interface LirauDiscoveryFeedLorauaContent : NSObject

@property (nonatomic, copy) NSArray<LirauTandemLearningLorauaRecommendation *> *tandemLearningLorauaRecommendations;
@property (nonatomic, copy) NSArray<LirauNarrativeSharingLorauaDynamicItem *> *talkShowItems;
@property (nonatomic, copy) NSArray<LirauNarrativeSharingLorauaDynamicItem *> *wordBitsItems;

+ (instancetype)mockDiscoveryFeedLorauaContent;

@end

NS_ASSUME_NONNULL_END
