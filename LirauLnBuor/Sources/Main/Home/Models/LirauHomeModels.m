#import "LirauHomeModels.h"

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

@implementation LirauHomeUserRecommendation

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    LirauHomeUserRecommendation *model = [[self alloc] init];
    model.userId = LirauStringValue(dictionary[@"conversationalAidsLoraua"]);
    model.name = LirauStringValue(dictionary[@"voiceMessageLoraua"]);
    model.avatarURLString = LirauStringValue(dictionary[@"interactiveFeedLoraua"]);
    model.brief = LirauStringValue(dictionary[@"localVernacularLoraua"]);
    if (model.name.length == 0) {
        model.name = @"LiraU Friend";
    }
    return model;
}

+ (instancetype)mockWithName:(NSString *)name brief:(NSString *)brief {
    LirauHomeUserRecommendation *model = [[self alloc] init];
    model.userId = [[NSUUID UUID] UUIDString];
    model.name = name;
    model.brief = brief;
    model.avatarURLString = @"";
    return model;
}

@end

@implementation LirauHomeDynamicItem

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    LirauHomeDynamicItem *model = [[self alloc] init];
    model.dynamicId = LirauStringValue(dictionary[@"realTimeChatLoraua"]);
    model.title = LirauStringValue(dictionary[@"vocalExpressionLoraua"]);
    model.content = LirauStringValue(dictionary[@"linguisticNuanceLoraua"]);
    model.userName = LirauStringValue(dictionary[@"contentDiscoveryLoraua"]);
    model.userAvatarURLString = LirauStringValue(dictionary[@"socialNetworkingLoraua"]);
    model.praiseCount = LirauIntegerValue(dictionary[@"verbalFluencyLoraua"]);
    model.storeCount = LirauIntegerValue(dictionary[@"communityBuildingLoraua"]);
    model.commentCount = LirauIntegerValue(dictionary[@"audioChattingLoraua"]);

    id images = dictionary[@"languageExchangeLoraua"] ?: dictionary[@"interactiveLearningLoraua"];
    if ([images isKindOfClass:NSArray.class] && [(NSArray *)images count] > 0) {
        model.imageURLString = LirauStringValue([(NSArray *)images firstObject]);
    } else {
        model.imageURLString = LirauStringValue(dictionary[@"languageSyllabusLoraua"]);
    }

    if (model.title.length == 0) {
        model.title = model.content.length > 0 ? model.content : @"Language Moment";
    }
    return model;
}

+ (instancetype)mockWithTitle:(NSString *)title content:(NSString *)content {
    LirauHomeDynamicItem *model = [[self alloc] init];
    model.dynamicId = [[NSUUID UUID] UUIDString];
    model.title = title;
    model.content = content;
    model.userName = @"LiraU";
    model.imageURLString = @"";
    model.userAvatarURLString = @"";
    model.praiseCount = 142;
    model.storeCount = 142;
    model.commentCount = 24;
    return model;
}

@end

@implementation LirauHomeContent

+ (instancetype)mockContent {
    LirauHomeContent *content = [[self alloc] init];
    content.recommendations = @[
        [LirauHomeUserRecommendation mockWithName:@"Luna Sprig" brief:@"Spanish daily chat"],
        [LirauHomeUserRecommendation mockWithName:@"Sunny Daze" brief:@"French culture notes"]
    ];
    content.talkShowItems = @[
        [LirauHomeDynamicItem mockWithTitle:@"Hand-Knitted Scarves" content:@"Practice warm daily greetings with language partners."],
        [LirauHomeDynamicItem mockWithTitle:@"Evening Accent Notes" content:@"Share a tiny sentence and compare regional sounds."],
        [LirauHomeDynamicItem mockWithTitle:@"Cultural Joke Swap" content:@"Meet someone through a short, friendly language prompt."]
    ];
    content.wordBitsItems = @[
        [LirauHomeDynamicItem mockWithTitle:@"Handcrafted Ceramic Mugs" content:@"A cozy phrase for starting cross-cultural conversations."],
        [LirauHomeDynamicItem mockWithTitle:@"Weekend Word Exchange" content:@"Collect easy phrases from native speakers."]
    ];
    return content;
}

@end
