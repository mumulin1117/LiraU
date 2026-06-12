#import "LirauProfileIntroLorauaManager.h"
#import "LirauEncryptionLorauaText.h"

static NSString *LirauProfileIntroLorauaBaseURLString(void) { return [LirauEncryptionLorauaText backendArchitectureLorauaBaseURL]; }
static NSString *LirauGlobalCitizenLorauaProfileDetailPath(void) { return [LirauEncryptionLorauaText profileIntroLorauaUserDetailPath]; }

@interface LirauProfileIntroLorauaManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LirauProfileIntroLorauaManager

+ (instancetype)sharedProfileIntroLorauaManager {
    static LirauProfileIntroLorauaManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LirauProfileIntroLorauaManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 30;
        configuration.timeoutIntervalForResource = 30;
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (void)loadProfileIntroLorauaContentWithCompletion:(LirauProfileIntroLorauaContentCompletion)completion {
    LirauProfileIntroLorauaContent *localProfileIntroLorauaContent = [self localProfileIntroLorauaContent];
    NSString *globalCitizenLorauaID = [self remoteGlobalCitizenLorauaIDFromLocalProfile:localProfileIntroLorauaContent.globalCitizenLorauaProfile];
    if (globalCitizenLorauaID.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LirauProfile" code:-4 userInfo:@{NSLocalizedDescriptionKey: @"Missing current user ID for profile detail request."}];
        completion(localProfileIntroLorauaContent, error, YES, NO);
        return;
    }

    NSDictionary *parameters = @{@"privacyProtectionLoraua": globalCitizenLorauaID};
    [self requestProfileIntroLorauaPath:LirauGlobalCitizenLorauaProfileDetailPath() parameters:parameters completion:^(id _Nullable data, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || ![data isKindOfClass:NSDictionary.class]) {
                completion(localProfileIntroLorauaContent, error, YES, YES);
                return;
            }

            NSDictionary *dictionary = (NSDictionary *)data;
            [localProfileIntroLorauaContent.globalCitizenLorauaProfile mergeGlobalCitizenLorauaRemoteDictionary:dictionary];
            NSArray *remotePosts = [self narrativeSharingLorauaPostsFromRemoteUserDictionary:dictionary fallbackAuthor:localProfileIntroLorauaContent.globalCitizenLorauaProfile.nativeSpeakerLorauaName];
            if ([dictionary[@"cloudHostingLoraua"] isKindOfClass:NSArray.class]) {
                localProfileIntroLorauaContent.posts = remotePosts;
                localProfileIntroLorauaContent.globalCitizenLorauaProfile.narrativeSharingLorauaPostCount = MAX(localProfileIntroLorauaContent.globalCitizenLorauaProfile.narrativeSharingLorauaPostCount, remotePosts.count);
            }
            completion(localProfileIntroLorauaContent, nil, NO, YES);
        });
    }];
}

- (LirauProfileIntroLorauaContent *)localProfileIntroLorauaContent {
    LirauProfileIntroLorauaContent *content = [[LirauProfileIntroLorauaContent alloc] init];
    content.globalCitizenLorauaProfile = [self localGlobalCitizenLorauaCurrentProfile];
    content.posts = [LirauProfileIntroLorauaContent mockDiscoveryFeedLorauaContent].posts;
    return content;
}

- (LirauGlobalCitizenLorauaProfile *)localGlobalCitizenLorauaCurrentProfile {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSString *emailMarketingLorauaCurrentEmail = [defaults stringForKey:[LirauEncryptionLorauaText emailMarketingLorauaCurrentEmailStorageKey]];
    if (emailMarketingLorauaCurrentEmail.length == 0) {
        return [LirauGlobalCitizenLorauaProfile globalCitizenLorauaTestProfile];
    }

    NSData *usersData = [defaults dataForKey:[LirauEncryptionLorauaText globalCommunityLorauaRegisteredUsersStorageKey]];
    if (usersData.length > 0) {
        NSError *error = nil;
        NSDictionary *users = [NSJSONSerialization JSONObjectWithData:usersData options:0 error:&error];
        if ([users isKindOfClass:NSDictionary.class]) {
            NSDictionary *userDictionary = users[emailMarketingLorauaCurrentEmail];
            if ([userDictionary isKindOfClass:NSDictionary.class]) {
                return [LirauGlobalCitizenLorauaProfile globalCitizenLorauaLocalProfileWithDictionary:userDictionary emailMarketingLorauaAddress:emailMarketingLorauaCurrentEmail];
            }
        }
    }

    if ([emailMarketingLorauaCurrentEmail isEqualToString:@"lariau@gmail.com"]) {
        return [LirauGlobalCitizenLorauaProfile globalCitizenLorauaTestProfile];
    }
    return [LirauGlobalCitizenLorauaProfile globalCitizenLorauaLocalProfileWithDictionary:@{@"email": emailMarketingLorauaCurrentEmail, @"displayName": @"LiraU Learner"} emailMarketingLorauaAddress:emailMarketingLorauaCurrentEmail];
}

- (NSString *)remoteGlobalCitizenLorauaIDFromLocalProfile:(LirauGlobalCitizenLorauaProfile *)profile {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    id storedUserID = [defaults objectForKey:[LirauEncryptionLorauaText identityVerificationLorauaUserIDStorageKey]];
    NSString *storedUserIDString = @"";
    if ([storedUserID isKindOfClass:NSString.class]) {
        storedUserIDString = (NSString *)storedUserID;
    } else if ([storedUserID respondsToSelector:@selector(stringValue)]) {
        storedUserIDString = [storedUserID stringValue];
    }
    if (storedUserIDString.length > 0) {
        return storedUserIDString;
    }

    NSString *localGlobalCitizenLorauaID = profile.globalCitizenLorauaID ?: @"";
    if (localGlobalCitizenLorauaID.length > 0 && ![localGlobalCitizenLorauaID hasPrefix:@"lirau_"]) {
        return localGlobalCitizenLorauaID;
    }
    return @"";
}

- (void)requestProfileIntroLorauaPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauProfileIntroLorauaBaseURLString() stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauProfile" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid profile endpoint."}]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = [LirauEncryptionLorauaText restfulAPILorauaPostMethod];
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [request setValue:[LirauEncryptionLorauaText apiFirstLorauaJSONMimeType] forHTTPHeaderField:[LirauEncryptionLorauaText apiFirstLorauaContentTypeHeader]];
    [request setValue:[LirauEncryptionLorauaText apiFirstLorauaJSONMimeType] forHTTPHeaderField:[LirauEncryptionLorauaText restfulAPILorauaAcceptHeader]];
    [request setValue:[LirauEncryptionLorauaText appIndexingLorauaAppKey] forHTTPHeaderField:[LirauEncryptionLorauaText apiFirstLorauaKeyHeader]];
    [request setValue:[self profileIntroLorauaSessionToken] forHTTPHeaderField:[LirauEncryptionLorauaText pointSystemLorauaTokenHeader]];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSLog(@"LiraU API Request Profile: url=%@ params=%@ token=%@", url.absoluteString, [self profileIntroLorauaDebugJSONStringFromObject:parameters], [self profileIntroLorauaMaskedSessionToken]);

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"LiraU API Failure Profile: url=%@ error=%@", url.absoluteString, error.localizedDescription);
            completion(nil, error);
            return;
        }

        NSInteger statusCode = [response isKindOfClass:NSHTTPURLResponse.class] ? ((NSHTTPURLResponse *)response).statusCode : -1;
        NSString *rawText = data.length > 0 ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"<empty response>";
        NSLog(@"LiraU API Response Profile: url=%@ status=%ld raw=%@", url.absoluteString, (long)statusCode, rawText ?: @"<non-utf8 response>");

        NSError *jsonError = nil;
        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
        if (jsonError || ![json isKindOfClass:NSDictionary.class]) {
            NSLog(@"LiraU API Invalid Profile: url=%@ error=%@", url.absoluteString, jsonError.localizedDescription ?: @"Invalid profile response.");
            completion(nil, jsonError ?: [NSError errorWithDomain:@"LirauProfile" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid profile response."}]);
            return;
        }

        NSDictionary *dictionary = (NSDictionary *)json;
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[[LirauEncryptionLorauaText restfulAPILorauaResponseCodeKey]] ?: dictionary[[LirauEncryptionLorauaText statusIndicatorLorauaResponseStatusKey]] ?: @""];
        NSLog(@"LiraU API Parsed Profile: path=%@ code=%@ data=%@", path, code, [self profileIntroLorauaDebugJSONStringFromObject:dictionary[[LirauEncryptionLorauaText dataAnalyticsLorauaResponseDataKey]]]);
        if (![self profileIntroLorauaIsSuccessCode:code]) {
            completion(nil, [NSError errorWithDomain:@"LirauProfile" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Profile request did not return success code."}]);
            return;
        }
        completion(dictionary[[LirauEncryptionLorauaText dataAnalyticsLorauaResponseDataKey]], nil);
    }];
    [task resume];
}

- (NSArray<LirauNarrativeSharingLorauaPost *> *)narrativeSharingLorauaPostsFromRemoteUserDictionary:(NSDictionary *)dictionary fallbackAuthor:(NSString *)fallbackAuthor {
    id list = dictionary[@"cloudHostingLoraua"];
    if (![list isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<LirauNarrativeSharingLorauaPost *> *posts = [NSMutableArray array];
    for (NSDictionary *postDictionary in (NSArray *)list) {
        if ([postDictionary isKindOfClass:NSDictionary.class]) {
            [posts addObject:[LirauNarrativeSharingLorauaPost narrativeSharingLorauaPostWithDictionary:postDictionary fallbackAuthor:fallbackAuthor]];
        }
    }
    return [posts copy];
}

- (NSString *)profileIntroLorauaSessionToken {
    NSString *token = [NSUserDefaults.standardUserDefaults objectForKey:[LirauEncryptionLorauaText pointSystemLorauaSessionTokenStorageKey]];
    return [token isKindOfClass:NSString.class] ? token : @"";
}

- (BOOL)profileIntroLorauaIsSuccessCode:(NSString *)code {
    return [code isEqualToString:[LirauEncryptionLorauaText statusIndicatorLorauaPrimarySuccessCode]] || [code isEqualToString:[LirauEncryptionLorauaText statusIndicatorLorauaSecondarySuccessCode]];
}

- (NSString *)profileIntroLorauaMaskedSessionToken {
    NSString *token = [self profileIntroLorauaSessionToken];
    if (token.length == 0) {
        return @"<empty>";
    }
    if (token.length <= 8) {
        return @"<masked>";
    }
    return [NSString stringWithFormat:@"%@...%@", [token substringToIndex:4], [token substringFromIndex:token.length - 4]];
}

- (NSString *)profileIntroLorauaDebugJSONStringFromObject:(id)object {
    if (!object) {
        return @"<nil>";
    }
    if (![NSJSONSerialization isValidJSONObject:object]) {
        return [object description] ?: @"<nil>";
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingSortedKeys error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: ([object description] ?: @"<nil>");
}

@end
