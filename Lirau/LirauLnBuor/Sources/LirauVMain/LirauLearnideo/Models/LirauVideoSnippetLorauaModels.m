#import "LirauVideoSnippetLorauaModels.h"

static NSString *LirauVideoSnippetLorauaStringValue(id value) {
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return @"";
}

static NSInteger LirauVideoSnippetLorauaIntegerValue(id value) {
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

@implementation LirauVSnippetLorauaItem

+ (instancetype)videoSnippetLorauaModelWithDictionary:(NSDictionary *)dictionary {
    LirauVSnippetLorauaItem *item = [[self alloc] init];
    item.dynamicId = LirauVideoSnippetLorauaStringValue(dictionary[@"realTimeChatLoraua"]);
    item.userId = LirauVideoSnippetLorauaStringValue(dictionary[@"dailyVloggingLoraua"]);
    item.userName = LirauVideoSnippetLorauaStringValue(dictionary[@"contentDiscoveryLoraua"]);
    item.userAvatarURLString = LirauVideoSnippetLorauaStringValue(dictionary[@"socialNetworkingLoraua"]);
    item.title = LirauVideoSnippetLorauaStringValue(dictionary[@"vocalExpressionLoraua"]);
    item.content = LirauVideoSnippetLorauaStringValue(dictionary[@"linguisticNuanceLoraua"]);
    item.videoCoverURLString = LirauVideoSnippetLorauaStringValue(dictionary[@"languageSyllabusLoraua"]);
    item.likeCount = LirauVideoSnippetLorauaIntegerValue(dictionary[@"verbalFluencyLoraua"]);
    item.commentCount = LirauVideoSnippetLorauaIntegerValue(dictionary[@"audioChattingLoraua"]);
    item.storeCount = LirauVideoSnippetLorauaIntegerValue(dictionary[@"communityBuildingLoraua"]);
    item.forwardCount = LirauVideoSnippetLorauaIntegerValue(dictionary[@"activeSpeakingLoraua"]);

    id images = dictionary[@"languageExchangeLoraua"] ?: dictionary[@"interactiveLearningLoraua"];
    if ([images isKindOfClass:NSArray.class] && [(NSArray *)images count] > 0) {
        item.fallbackImageURLString = LirauVideoSnippetLorauaStringValue([(NSArray *)images firstObject]);
    } else {
        item.fallbackImageURLString = @"";
    }
    if (item.userName.length == 0) {
        item.userName = @"LiraU Friend";
    }
    if (item.title.length == 0) {
        item.title = item.content.length > 0 ? item.content : @"Language Moment";
    }
    return item;
}

+ (instancetype)mockVideoSnippetLorauaItemWithTitle:(NSString *)title userName:(NSString *)userName {
    LirauVSnippetLorauaItem *item = [[self alloc] init];
    item.dynamicId = [[NSUUID UUID] UUIDString];
    item.userId = [[NSUUID UUID] UUIDString];
    item.userName = userName;
    item.title = title;
    item.content = @"Sunday afternoons are for creating language memories.";
    item.videoCoverURLString = @"";
    item.fallbackImageURLString = @"";
    item.likeCount = 142;
    item.commentCount = 24;
    item.storeCount = 36;
    item.forwardCount = 12;
    return item;
}

- (NSString *)videoSnippetLorauaDisplayCoverURLString {
    return self.videoCoverURLString.length > 0 ? self.videoCoverURLString : self.fallbackImageURLString;
}

- (NSString *)videoSnippetLorauaDisplayDescription {
    if (self.content.length > 0) {
        return self.content;
    }
    return self.title;
}

@end
