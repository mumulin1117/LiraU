#import "LirauVideoModels.h"

static NSString *LirauVideoStringValue(id value) {
    if ([value isKindOfClass:NSString.class]) {
        return value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return @"";
}

static NSInteger LirauVideoIntegerValue(id value) {
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

@implementation LirauVideoItem

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    LirauVideoItem *item = [[self alloc] init];
    item.dynamicId = LirauVideoStringValue(dictionary[@"realTimeChatLoraua"]);
    item.userId = LirauVideoStringValue(dictionary[@"dailyVloggingLoraua"]);
    item.userName = LirauVideoStringValue(dictionary[@"contentDiscoveryLoraua"]);
    item.userAvatarURLString = LirauVideoStringValue(dictionary[@"socialNetworkingLoraua"]);
    item.title = LirauVideoStringValue(dictionary[@"vocalExpressionLoraua"]);
    item.content = LirauVideoStringValue(dictionary[@"linguisticNuanceLoraua"]);
    item.videoCoverURLString = LirauVideoStringValue(dictionary[@"languageSyllabusLoraua"]);
    item.likeCount = LirauVideoIntegerValue(dictionary[@"verbalFluencyLoraua"]);
    item.commentCount = LirauVideoIntegerValue(dictionary[@"audioChattingLoraua"]);
    item.storeCount = LirauVideoIntegerValue(dictionary[@"communityBuildingLoraua"]);
    item.forwardCount = LirauVideoIntegerValue(dictionary[@"activeSpeakingLoraua"]);

    id images = dictionary[@"languageExchangeLoraua"] ?: dictionary[@"interactiveLearningLoraua"];
    if ([images isKindOfClass:NSArray.class] && [(NSArray *)images count] > 0) {
        item.fallbackImageURLString = LirauVideoStringValue([(NSArray *)images firstObject]);
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

+ (instancetype)mockWithTitle:(NSString *)title userName:(NSString *)userName {
    LirauVideoItem *item = [[self alloc] init];
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

- (NSString *)displayCoverURLString {
    return self.videoCoverURLString.length > 0 ? self.videoCoverURLString : self.fallbackImageURLString;
}

- (NSString *)displayDescription {
    if (self.content.length > 0) {
        return self.content;
    }
    return self.title;
}

@end
