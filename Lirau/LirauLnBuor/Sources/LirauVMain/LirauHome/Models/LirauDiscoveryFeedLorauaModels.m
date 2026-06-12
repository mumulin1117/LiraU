#import "LirauDiscoveryFeedLorauaModels.h"

static NSString *LirauStringValue(id value) {
    if ([value isKindOfClass:NSString.class]) {
        return (NSString *)value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return @"";
}

static NSInteger LirauIntegerValue(id value) {
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

static NSString *LirauFirstImageURLValue(id value) {
    if ([value isKindOfClass:NSArray.class]) {
        id firstObject = [(NSArray *)value firstObject];
        if ([firstObject isKindOfClass:NSString.class]) {
            return LirauStringValue(firstObject);
        }
        if ([firstObject isKindOfClass:NSDictionary.class]) {
            NSDictionary *dictionary = (NSDictionary *)firstObject;
            for (NSString *key in @[@"url", @"imgUrl", @"imageUrl", @"languageSyllabusLoraua"]) {
                NSString *urlString = LirauStringValue(dictionary[key]);
                if (urlString.length > 0) {
                    return urlString;
                }
            }
        }
    }
    return LirauStringValue(value);
}

@implementation LirauTandemLearningLorauaRecommendation

+ (instancetype)discoveryFeedLorauaModelWithDictionary:(NSDictionary *)dictionary {
    LirauTandemLearningLorauaRecommendation *model = [[self alloc] init];
    model.languageExchangePartnerLorauaID = LirauStringValue(dictionary[@"conversationalAidsLoraua"]);
    model.nativeSpeakerLorauaName = LirauStringValue(dictionary[@"voiceMessageLoraua"]);
    model.avatarChatLorauaURLString = LirauStringValue(dictionary[@"interactiveFeedLoraua"]);
    model.conversationStarterLorauaBrief = LirauStringValue(dictionary[@"localVernacularLoraua"]);
    if (model.nativeSpeakerLorauaName.length == 0) {
        model.nativeSpeakerLorauaName = @"LiraU Friend";
    }
    return model;
}

+ (instancetype)mockTandemLearningLorauaRecommendationWithName:(NSString *)nativeSpeakerLorauaName conversationStarterLorauaBrief:(NSString *)conversationStarterLorauaBrief {
    LirauTandemLearningLorauaRecommendation *model = [[self alloc] init];
    model.languageExchangePartnerLorauaID = [[NSUUID UUID] UUIDString];
    model.nativeSpeakerLorauaName = nativeSpeakerLorauaName;
    model.conversationStarterLorauaBrief = conversationStarterLorauaBrief;
    model.avatarChatLorauaURLString = @"lira_profile_avatar_default";
    return model;
}

@end

@implementation LirauNarrativeSharingLorauaDynamicItem

+ (instancetype)discoveryFeedLorauaModelWithDictionary:(NSDictionary *)dictionary {
    LirauNarrativeSharingLorauaDynamicItem *model = [[self alloc] init];
    model.dynamicId = LirauStringValue(dictionary[@"realTimeChatLoraua"]);
    model.title = LirauStringValue(dictionary[@"vocalExpressionLoraua"]);
    model.content = LirauStringValue(dictionary[@"linguisticNuanceLoraua"]);
    model.userName = LirauStringValue(dictionary[@"contentDiscoveryLoraua"]);
    model.userAvatarURLString = LirauStringValue(dictionary[@"socialNetworkingLoraua"]);
    model.praiseCount = LirauIntegerValue(dictionary[@"verbalFluencyLoraua"]);
    model.storeCount = LirauIntegerValue(dictionary[@"communityBuildingLoraua"]);
    model.commentCount = LirauIntegerValue(dictionary[@"audioChattingLoraua"]);

    model.imageURLString = LirauFirstImageURLValue(dictionary[@"languageExchangeLoraua"]);
    if (model.imageURLString.length == 0) {
        model.imageURLString = LirauFirstImageURLValue(dictionary[@"interactiveLearningLoraua"]);
    }
    if (model.imageURLString.length == 0) {
        model.imageURLString = LirauStringValue(dictionary[@"languageSyllabusLoraua"]);
    }

    if (model.title.length == 0) {
        model.title = model.content.length > 0 ? model.content : @"Language Moment";
    }
    return model;
}

+ (instancetype)mockNarrativeSharingLorauaDynamicWithTitle:(NSString *)title content:(NSString *)content {
    LirauNarrativeSharingLorauaDynamicItem *model = [[self alloc] init];
    model.dynamicId = [[NSUUID UUID] UUIDString];
    model.title = title;
    model.content = content;
    model.userName = @"LiraU";
    model.imageURLString = @"lira_profile_post_placeholder";
    model.userAvatarURLString = @"lira_profile_avatar_default";
    model.praiseCount = 142;
    model.storeCount = 142;
    model.commentCount = 24;
    return model;
}

@end

@implementation LirauDiscoveryFeedLorauaContent

+ (instancetype)mockDiscoveryFeedLorauaContent {
    LirauDiscoveryFeedLorauaContent *content = [[self alloc] init];
    content.tandemLearningLorauaRecommendations = @[
        [LirauTandemLearningLorauaRecommendation mockTandemLearningLorauaRecommendationWithName:@"Luna Sprig" conversationStarterLorauaBrief:@"Spanish daily chat"],
        [LirauTandemLearningLorauaRecommendation mockTandemLearningLorauaRecommendationWithName:@"Sunny Daze" conversationStarterLorauaBrief:@"French culture notes"]
    ];
    content.talkShowItems = @[
        [LirauNarrativeSharingLorauaDynamicItem mockNarrativeSharingLorauaDynamicWithTitle:@"Hand-Knitted Scarves" content:@"Practice warm daily greetings with language partners."],
        [LirauNarrativeSharingLorauaDynamicItem mockNarrativeSharingLorauaDynamicWithTitle:@"Evening Accent Notes" content:@"Share a tiny sentence and compare regional sounds."],
        [LirauNarrativeSharingLorauaDynamicItem mockNarrativeSharingLorauaDynamicWithTitle:@"Cultural Joke Swap" content:@"Meet someone through a short, friendly language prompt."]
    ];
    content.wordBitsItems = @[
        [LirauNarrativeSharingLorauaDynamicItem mockNarrativeSharingLorauaDynamicWithTitle:@"Handcrafted Ceramic Mugs" content:@"A cozy phrase for starting cross-cultural conversations."],
        [LirauNarrativeSharingLorauaDynamicItem mockNarrativeSharingLorauaDynamicWithTitle:@"Weekend Word Exchange" content:@"Collect easy phrases from native speakers."]
    ];
    return content;
}

@end
