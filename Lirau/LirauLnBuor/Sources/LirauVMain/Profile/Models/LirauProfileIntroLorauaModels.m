#import "LirauProfileIntroLorauaModels.h"

static NSString *LirauProfileIntroLorauaStringValue(id value) {
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

static NSInteger LirauProfileIntroLorauaIntegerValue(id value) {
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

@implementation LirauGlobalCitizenLorauaProfile

+ (instancetype)globalCitizenLorauaLocalProfileWithDictionary:(NSDictionary *)dictionary emailMarketingLorauaAddress:(NSString *)emailMarketingLorauaAddress {
    LirauGlobalCitizenLorauaProfile *profile = [[self alloc] init];
    NSString *localEmail = LirauProfileIntroLorauaStringValue(dictionary[@"emailMarketingLorauaAddress"]);
    if (localEmail.length == 0) {
        localEmail = LirauProfileIntroLorauaStringValue(dictionary[@"email"]);
    }
    NSString *localName = LirauProfileIntroLorauaStringValue(dictionary[@"nativeSpeakerLorauaName"]);
    if (localName.length == 0) {
        localName = LirauProfileIntroLorauaStringValue(dictionary[@"displayName"]);
    }
    profile.globalCitizenLorauaID = LirauProfileIntroLorauaStringValue(dictionary[@"globalCitizenLorauaID"]);
    if (profile.globalCitizenLorauaID.length == 0) {
        profile.globalCitizenLorauaID = LirauProfileIntroLorauaStringValue(dictionary[@"userID"]);
    }
    profile.emailMarketingLorauaAddress = localEmail.length > 0 ? localEmail : emailMarketingLorauaAddress;
    profile.nativeSpeakerLorauaName = localName.length > 0 ? localName : @"LiraU Learner";
    profile.profileIntroLorauaBio = LirauProfileIntroLorauaStringValue(dictionary[@"profileIntroLorauaBio"]);
    if (profile.profileIntroLorauaBio.length == 0) {
        profile.profileIntroLorauaBio = LirauProfileIntroLorauaStringValue(dictionary[@"profileIntroLoraua"]);
    }
    profile.languagePairingLorauaSummary = LirauProfileIntroLorauaStringValue(dictionary[@"languagePairingLorauaSummary"]);
    if (profile.languagePairingLorauaSummary.length == 0) {
        profile.languagePairingLorauaSummary = LirauProfileIntroLorauaStringValue(dictionary[@"languagePairingLoraua"]);
    }
    NSString *localBalance = LirauProfileIntroLorauaStringValue(dictionary[@"linguisticAdaptationLoraua"]);
    if (localBalance.length == 0) {
        localBalance = LirauProfileIntroLorauaStringValue(dictionary[@"virtualCurrencyLorauaBalance"]);
    }
    if (localBalance.length == 0) {
        localBalance = LirauProfileIntroLorauaStringValue(dictionary[@"userBalance"]);
    }
    if (localBalance.length == 0) {
        localBalance = LirauProfileIntroLorauaStringValue(dictionary[@"walletBalance"]);
    }
    profile.virtualCurrencyLorauaBalance = localBalance.length > 0 ? localBalance : @"0";
    profile.peerLearningLorauaFollowingCount = 245;
    profile.narrativeSharingLorauaPostCount = 100;
    profile.globalCommunityLorauaFollowersCount = 336;
    return profile;
}

+ (instancetype)globalCitizenLorauaTestProfile {
    return [self globalCitizenLorauaLocalProfileWithDictionary:@{
        @"userID": @"lirau_test_user",
        @"email": @"lariau@gmail.com",
        @"displayName": @"LiraU Speaker",
        @"profileIntroLoraua": @"Practicing Spanish jokes and sharing everyday culture.",
        @"languagePairingLoraua": @"English - Spanish"
    } emailMarketingLorauaAddress:@"lariau@gmail.com"];
}

- (void)mergeGlobalCitizenLorauaRemoteDictionary:(NSDictionary *)dictionary {
    NSString *remoteName = LirauProfileIntroLorauaStringValue(dictionary[@"assetManagementLoraua"]);
    if (remoteName.length == 0) {
        remoteName = LirauProfileIntroLorauaStringValue(dictionary[@"automatedModerationLoraua"]);
    }
    if (remoteName.length > 0) {
        self.nativeSpeakerLorauaName = remoteName;
    }

    NSString *avatar = LirauProfileIntroLorauaStringValue(dictionary[@"codeObfuscationLoraua"]);
    if (avatar.length == 0) {
        avatar = LirauProfileIntroLorauaStringValue(dictionary[@"communityStandardLoraua"]);
    }
    if (avatar.length > 0) {
        self.avatarChatLorauaURLString = avatar;
    }

    NSString *remoteEmail = LirauProfileIntroLorauaStringValue(dictionary[@"reviewComplianceLoraua"]);
    if (remoteEmail.length == 0) {
        remoteEmail = LirauProfileIntroLorauaStringValue(dictionary[@"reportingMechanismLoraua"]);
    }
    if (remoteEmail.length > 0) {
        self.emailMarketingLorauaAddress = remoteEmail;
    }

    NSString *remoteUserID = LirauProfileIntroLorauaStringValue(dictionary[@"responsiveDesignLoraua"]);
    if (remoteUserID.length == 0) {
        remoteUserID = LirauProfileIntroLorauaStringValue(dictionary[@"moderationToolLoraua"]);
    }
    if (remoteUserID.length > 0) {
        self.globalCitizenLorauaID = remoteUserID;
    }

    NSString *brief = LirauProfileIntroLorauaStringValue(dictionary[@"appStoreSubmissionLoraua"]);
    if (brief.length == 0) {
        brief = LirauProfileIntroLorauaStringValue(dictionary[@"userFeedbackLoraua"]);
    }
    if (brief.length > 0) {
        self.profileIntroLorauaBio = brief;
    }

    NSString *remoteBalance = LirauProfileIntroLorauaStringValue(dictionary[@"linguisticAdaptationLoraua"]);
    if (remoteBalance.length == 0) {
        remoteBalance = LirauProfileIntroLorauaStringValue(dictionary[@"userBalance"]);
    }
    if (remoteBalance.length == 0) {
        remoteBalance = LirauProfileIntroLorauaStringValue(dictionary[@"walletBalance"]);
    }
    if (remoteBalance.length > 0) {
        self.virtualCurrencyLorauaBalance = remoteBalance;
    }

    if (dictionary[@"crashAnalyticsLoraua"]) {
        self.globalCommunityLorauaFollowersCount = MAX(0, LirauProfileIntroLorauaIntegerValue(dictionary[@"crashAnalyticsLoraua"]));
    }
    if (dictionary[@"bugTrackingLoraua"]) {
        self.peerLearningLorauaFollowingCount = MAX(0, LirauProfileIntroLorauaIntegerValue(dictionary[@"bugTrackingLoraua"]));
    }
    if (dictionary[@"performanceOptimizationLoraua"]) {
        self.narrativeSharingLorauaPostCount = MAX(0, LirauProfileIntroLorauaIntegerValue(dictionary[@"performanceOptimizationLoraua"]));
    }
}

@end

@implementation LirauNarrativeSharingLorauaPost

+ (instancetype)narrativeSharingLorauaPostWithDictionary:(NSDictionary *)dictionary fallbackAuthor:(NSString *)fallbackAuthor {
    LirauNarrativeSharingLorauaPost *post = [[self alloc] init];
    post.postID = LirauProfileIntroLorauaStringValue(dictionary[@"realTimeChatLoraua"]);
    post.title = LirauProfileIntroLorauaStringValue(dictionary[@"vocalExpressionLoraua"]);
    post.content = LirauProfileIntroLorauaStringValue(dictionary[@"linguisticNuanceLoraua"]);
    post.authorName = LirauProfileIntroLorauaStringValue(dictionary[@"contentDiscoveryLoraua"]).length > 0 ? LirauProfileIntroLorauaStringValue(dictionary[@"contentDiscoveryLoraua"]) : fallbackAuthor;
    post.authorAvatarURLString = LirauProfileIntroLorauaStringValue(dictionary[@"socialNetworkingLoraua"]);
    post.videoCoverURLString = LirauProfileIntroLorauaStringValue(dictionary[@"languageSyllabusLoraua"]);
    post.hasVideo = post.videoCoverURLString.length > 0;

    NSArray *imageList = dictionary[@"languageExchangeLoraua"];
    if (![imageList isKindOfClass:NSArray.class]) {
        imageList = dictionary[@"interactiveLearningLoraua"];
    }
    if ([imageList isKindOfClass:NSArray.class] && imageList.count > 0) {
        post.coverURLString = LirauProfileIntroLorauaStringValue(imageList.firstObject);
    }
    if (post.coverURLString.length == 0) {
        post.coverURLString = post.videoCoverURLString;
    }
    if (post.title.length == 0) {
        post.title = post.content.length > 0 ? post.content : @"Daily language moment";
    }
    return post;
}

+ (instancetype)mockNarrativeSharingLorauaPostWithTitle:(NSString *)title authorName:(NSString *)authorName {
    LirauNarrativeSharingLorauaPost *post = [[self alloc] init];
    post.postID = [[NSUUID UUID] UUIDString];
    post.title = title;
    post.content = title;
    post.authorName = authorName;
    post.hasVideo = YES;
    return post;
}

@end

@implementation LirauProfileIntroLorauaContent

+ (instancetype)mockDiscoveryFeedLorauaContent {
    LirauProfileIntroLorauaContent *content = [[self alloc] init];
    content.globalCitizenLorauaProfile = [LirauGlobalCitizenLorauaProfile globalCitizenLorauaTestProfile];
    content.posts = @[
        [LirauNarrativeSharingLorauaPost mockNarrativeSharingLorauaPostWithTitle:@"Surround yourself with a new phrase from today's language circle." authorName:@"Kyle"],
        [LirauNarrativeSharingLorauaPost mockNarrativeSharingLorauaPostWithTitle:@"Share a tiny story and listen for a new accent." authorName:@"Kyle"]
    ];
    return content;
}

@end
