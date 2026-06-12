#import "LirauProfileModels.h"

static NSString *LirauProfileStringValue(id value) {
    if (!value || value == NSNull.null) {
        return @"";
    }
    if ([value isKindOfClass:NSString.class]) {
        return (NSString *)value;
    }
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return @"";
}

static NSInteger LirauProfileIntegerValue(id value) {
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

@implementation LirauProfileUser

+ (instancetype)localUserWithDictionary:(NSDictionary *)dictionary email:(NSString *)email {
    LirauProfileUser *user = [[self alloc] init];
    user.userID = LirauProfileStringValue(dictionary[@"userID"]);
    user.email = LirauProfileStringValue(dictionary[@"email"]).length > 0 ? LirauProfileStringValue(dictionary[@"email"]) : email;
    user.displayName = LirauProfileStringValue(dictionary[@"displayName"]).length > 0 ? LirauProfileStringValue(dictionary[@"displayName"]) : @"LiraU Learner";
    user.profileIntroLoraua = LirauProfileStringValue(dictionary[@"profileIntroLoraua"]);
    user.languagePairingLoraua = LirauProfileStringValue(dictionary[@"languagePairingLoraua"]);
    NSString *localBalance = LirauProfileStringValue(dictionary[@"linguisticAdaptationLoraua"]);
    if (localBalance.length == 0) {
        localBalance = LirauProfileStringValue(dictionary[@"userBalance"]);
    }
    if (localBalance.length == 0) {
        localBalance = LirauProfileStringValue(dictionary[@"walletBalance"]);
    }
    user.walletBalance = localBalance.length > 0 ? localBalance : @"0";
    user.followingCount = 245;
    user.postCount = 100;
    user.followersCount = 336;
    return user;
}

+ (instancetype)testUser {
    return [self localUserWithDictionary:@{
        @"userID": @"lirau_test_user",
        @"email": @"lariau@gmail.com",
        @"displayName": @"LiraU Speaker",
        @"profileIntroLoraua": @"Practicing Spanish jokes and sharing everyday culture.",
        @"languagePairingLoraua": @"English - Spanish"
    } email:@"lariau@gmail.com"];
}

- (void)mergeRemoteDictionary:(NSDictionary *)dictionary {
    NSString *remoteName = LirauProfileStringValue(dictionary[@"assetManagementLoraua"]);
    if (remoteName.length == 0) {
        remoteName = LirauProfileStringValue(dictionary[@"automatedModerationLoraua"]);
    }
    if (remoteName.length > 0) {
        self.displayName = remoteName;
    }

    NSString *avatar = LirauProfileStringValue(dictionary[@"codeObfuscationLoraua"]);
    if (avatar.length == 0) {
        avatar = LirauProfileStringValue(dictionary[@"communityStandardLoraua"]);
    }
    if (avatar.length > 0) {
        self.avatarURLString = avatar;
    }

    NSString *remoteEmail = LirauProfileStringValue(dictionary[@"reviewComplianceLoraua"]);
    if (remoteEmail.length == 0) {
        remoteEmail = LirauProfileStringValue(dictionary[@"reportingMechanismLoraua"]);
    }
    if (remoteEmail.length > 0) {
        self.email = remoteEmail;
    }

    NSString *remoteUserID = LirauProfileStringValue(dictionary[@"responsiveDesignLoraua"]);
    if (remoteUserID.length == 0) {
        remoteUserID = LirauProfileStringValue(dictionary[@"moderationToolLoraua"]);
    }
    if (remoteUserID.length > 0) {
        self.userID = remoteUserID;
    }

    NSString *brief = LirauProfileStringValue(dictionary[@"appStoreSubmissionLoraua"]);
    if (brief.length == 0) {
        brief = LirauProfileStringValue(dictionary[@"userFeedbackLoraua"]);
    }
    if (brief.length > 0) {
        self.profileIntroLoraua = brief;
    }

    NSString *remoteBalance = LirauProfileStringValue(dictionary[@"linguisticAdaptationLoraua"]);
    if (remoteBalance.length == 0) {
        remoteBalance = LirauProfileStringValue(dictionary[@"userBalance"]);
    }
    if (remoteBalance.length == 0) {
        remoteBalance = LirauProfileStringValue(dictionary[@"walletBalance"]);
    }
    if (remoteBalance.length > 0) {
        self.walletBalance = remoteBalance;
    }

    if (dictionary[@"crashAnalyticsLoraua"]) {
        self.followersCount = MAX(0, LirauProfileIntegerValue(dictionary[@"crashAnalyticsLoraua"]));
    }
    if (dictionary[@"bugTrackingLoraua"]) {
        self.followingCount = MAX(0, LirauProfileIntegerValue(dictionary[@"bugTrackingLoraua"]));
    }
    if (dictionary[@"performanceOptimizationLoraua"]) {
        self.postCount = MAX(0, LirauProfileIntegerValue(dictionary[@"performanceOptimizationLoraua"]));
    }
}

@end

@implementation LirauProfilePost

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary fallbackAuthor:(NSString *)fallbackAuthor {
    LirauProfilePost *post = [[self alloc] init];
    post.postID = LirauProfileStringValue(dictionary[@"realTimeChatLoraua"]);
    post.title = LirauProfileStringValue(dictionary[@"vocalExpressionLoraua"]);
    post.content = LirauProfileStringValue(dictionary[@"linguisticNuanceLoraua"]);
    post.authorName = LirauProfileStringValue(dictionary[@"contentDiscoveryLoraua"]).length > 0 ? LirauProfileStringValue(dictionary[@"contentDiscoveryLoraua"]) : fallbackAuthor;
    post.authorAvatarURLString = LirauProfileStringValue(dictionary[@"socialNetworkingLoraua"]);
    post.videoCoverURLString = LirauProfileStringValue(dictionary[@"languageSyllabusLoraua"]);
    post.hasVideo = post.videoCoverURLString.length > 0;

    NSArray *imageList = dictionary[@"languageExchangeLoraua"];
    if (![imageList isKindOfClass:NSArray.class]) {
        imageList = dictionary[@"interactiveLearningLoraua"];
    }
    if ([imageList isKindOfClass:NSArray.class] && imageList.count > 0) {
        post.coverURLString = LirauProfileStringValue(imageList.firstObject);
    }
    if (post.coverURLString.length == 0) {
        post.coverURLString = post.videoCoverURLString;
    }
    if (post.title.length == 0) {
        post.title = post.content.length > 0 ? post.content : @"Daily language moment";
    }
    return post;
}

+ (instancetype)mockWithTitle:(NSString *)title authorName:(NSString *)authorName {
    LirauProfilePost *post = [[self alloc] init];
    post.postID = [[NSUUID UUID] UUIDString];
    post.title = title;
    post.content = title;
    post.authorName = authorName;
    post.hasVideo = YES;
    return post;
}

@end

@implementation LirauProfileContent

+ (instancetype)mockContent {
    LirauProfileContent *content = [[self alloc] init];
    content.user = [LirauProfileUser testUser];
    content.posts = @[
        [LirauProfilePost mockWithTitle:@"Surround yourself with a new phrase from today's language circle." authorName:@"Kyle"],
        [LirauProfilePost mockWithTitle:@"Share a tiny story and listen for a new accent." authorName:@"Kyle"]
    ];
    return content;
}

@end
