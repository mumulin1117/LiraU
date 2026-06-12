#import "LirauDiscoveryFeedLorauaManager.h"
#import "LirauEncryptionLorauaText.h"

static NSString *LirauDiscoveryFeedLorauaBaseURLString(void) { return [LirauEncryptionLorauaText backendArchitectureLorauaBaseURL]; }
static NSString *LirauDiscoveryFeedLorauaUserIndexPath(void) { return [LirauEncryptionLorauaText discoveryFeedLorauaUserIndexPath]; }
static NSString *LirauNarrativeSharingLorauaDynamicListPath(void) { return [LirauEncryptionLorauaText narrativeSharingLorauaDynamicListPath]; }

@interface LirauDiscoveryFeedLorauaManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LirauDiscoveryFeedLorauaManager

+ (instancetype)sharedDiscoveryFeedLorauaManager {
    static LirauDiscoveryFeedLorauaManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LirauDiscoveryFeedLorauaManager alloc] init];
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

- (void)loadDiscoveryFeedLorauaContentWithCompletion:(LirauDiscoveryFeedLorauaContentCompletion)completion {
    dispatch_group_t group = dispatch_group_create();
    __block NSArray<LirauTandemLearningLorauaRecommendation *> *tandemLearningLorauaRecommendations = @[];
    __block NSArray<LirauNarrativeSharingLorauaDynamicItem *> *talkShow = @[];
    __block NSArray<LirauNarrativeSharingLorauaDynamicItem *> *wordBits = @[];
    __block NSError *lastError = nil;

    dispatch_group_enter(group);
    [self requestDiscoveryFeedLorauaPath:LirauDiscoveryFeedLorauaUserIndexPath()
           parameters:@{@"culturalImmersionLoraua": [self appIndexingLorauaBundleIdentifier]}
           completion:^(id _Nullable data, NSError *_Nullable error) {
        if (error) {
            lastError = error;
        } else {
            tandemLearningLorauaRecommendations = [self parseTandemLearningLorauaRecommendationsFromData:data];
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self requestDiscoveryFeedLorauaPath:LirauNarrativeSharingLorauaDynamicListPath()
           parameters:@{
               @"globalConnectivityLoraua": [self appIndexingLorauaBundleIdentifier],
               @"languageJourneyLoraua": @5,
               @"microLearningLoraua": @2,
               @"audioStreamingLoraua": @1,
               @"userEngagementLoraua": @10
           }
           completion:^(id _Nullable data, NSError *_Nullable error) {
        if (error) {
            lastError = error;
        } else {
            talkShow = [self parseNarrativeSharingLorauaDynamicsFromData:data];
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self requestDiscoveryFeedLorauaPath:LirauNarrativeSharingLorauaDynamicListPath()
           parameters:@{
               @"globalConnectivityLoraua": [self appIndexingLorauaBundleIdentifier],
               @"languageJourneyLoraua": @4,
               @"audioStreamingLoraua": @1,
               @"userEngagementLoraua": @10
           }
           completion:^(id _Nullable data, NSError *_Nullable error) {
        if (error) {
            lastError = error;
        } else {
            wordBits = [self parseNarrativeSharingLorauaDynamicsFromData:data];
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (tandemLearningLorauaRecommendations.count == 0 && talkShow.count == 0 && wordBits.count == 0) {
            LirauDiscoveryFeedLorauaContent *fallback = [LirauDiscoveryFeedLorauaContent mockDiscoveryFeedLorauaContent];
            completion(fallback, lastError, YES);
            return;
        }

        LirauDiscoveryFeedLorauaContent *content = [[LirauDiscoveryFeedLorauaContent alloc] init];
        LirauDiscoveryFeedLorauaContent *mockDiscoveryFeedLorauaContent = [LirauDiscoveryFeedLorauaContent mockDiscoveryFeedLorauaContent];
        content.tandemLearningLorauaRecommendations = tandemLearningLorauaRecommendations.count > 0 ? tandemLearningLorauaRecommendations : mockDiscoveryFeedLorauaContent.tandemLearningLorauaRecommendations;
        content.talkShowItems = talkShow.count > 0 ? talkShow : mockDiscoveryFeedLorauaContent.talkShowItems;
        content.wordBitsItems = wordBits.count > 0 ? wordBits : mockDiscoveryFeedLorauaContent.wordBitsItems;
        completion(content, lastError, tandemLearningLorauaRecommendations.count == 0 || talkShow.count == 0 || wordBits.count == 0);
    });
}

- (void)requestDiscoveryFeedLorauaPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauDiscoveryFeedLorauaBaseURLString() stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauDiscoveryFeedLoraua" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid discovery feed endpoint."}]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = [LirauEncryptionLorauaText restfulAPILorauaPostMethod];
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [request setValue:[LirauEncryptionLorauaText apiFirstLorauaJSONMimeType] forHTTPHeaderField:[LirauEncryptionLorauaText apiFirstLorauaContentTypeHeader]];
    [request setValue:[LirauEncryptionLorauaText apiFirstLorauaJSONMimeType] forHTTPHeaderField:[LirauEncryptionLorauaText restfulAPILorauaAcceptHeader]];
    [request setValue:[LirauEncryptionLorauaText appIndexingLorauaAppKey] forHTTPHeaderField:[LirauEncryptionLorauaText apiFirstLorauaKeyHeader]];
    [request setValue:[self sessionTokenLoraua] forHTTPHeaderField:[LirauEncryptionLorauaText pointSystemLorauaTokenHeader]];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSLog(@"LiraU API Request DiscoveryFeedLoraua: url=%@ params=%@ token=%@", url.absoluteString, [self dataAnalyticsLorauaDebugJSONStringFromObject:parameters], [self maskedSessionTokenLoraua]);

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"LiraU API Failure DiscoveryFeedLoraua: url=%@ error=%@", url.absoluteString, error.localizedDescription);
            completion(nil, error);
            return;
        }

        NSInteger statusCode = [response isKindOfClass:NSHTTPURLResponse.class] ? ((NSHTTPURLResponse *)response).statusCode : -1;
        NSString *rawText = data.length > 0 ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"<empty response>";
        NSLog(@"LiraU API Response DiscoveryFeedLoraua: url=%@ status=%ld raw=%@", url.absoluteString, (long)statusCode, rawText ?: @"<non-utf8 response>");

        NSError *jsonError = nil;
        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
        if (jsonError || ![json isKindOfClass:NSDictionary.class]) {
            NSLog(@"LiraU API Invalid DiscoveryFeedLoraua: url=%@ error=%@", url.absoluteString, jsonError.localizedDescription ?: @"Invalid discovery feed response.");
            completion(nil, jsonError ?: [NSError errorWithDomain:@"LirauDiscoveryFeedLoraua" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid discovery feed response."}]);
            return;
        }

        NSDictionary *dictionary = (NSDictionary *)json;
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[[LirauEncryptionLorauaText restfulAPILorauaResponseCodeKey]] ?: dictionary[[LirauEncryptionLorauaText statusIndicatorLorauaResponseStatusKey]] ?: @""];
        NSLog(@"LiraU API Parsed DiscoveryFeedLoraua: path=%@ code=%@ data=%@", path, code, [self dataAnalyticsLorauaDebugJSONStringFromObject:dictionary[[LirauEncryptionLorauaText dataAnalyticsLorauaResponseDataKey]]]);
        if (![self statusIndicatorLorauaIsSuccessCode:code]) {
            completion(nil, [NSError errorWithDomain:@"LirauDiscoveryFeedLoraua" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Discovery feed request did not return success code."}]);
            return;
        }
        completion(dictionary[[LirauEncryptionLorauaText dataAnalyticsLorauaResponseDataKey]], nil);
    }];
    [task resume];
}

- (NSArray<LirauTandemLearningLorauaRecommendation *> *)parseTandemLearningLorauaRecommendationsFromData:(id)data {
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *dictionary in [self contentCurationLorauaArrayPayloadFromData:data]) {
        if ([dictionary isKindOfClass:NSDictionary.class]) {
            [models addObject:[LirauTandemLearningLorauaRecommendation discoveryFeedLorauaModelWithDictionary:dictionary]];
        }
    }
    return [models copy];
}

- (NSArray<LirauNarrativeSharingLorauaDynamicItem *> *)parseNarrativeSharingLorauaDynamicsFromData:(id)data {
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *dictionary in [self contentCurationLorauaArrayPayloadFromData:data]) {
        if ([dictionary isKindOfClass:NSDictionary.class]) {
            [models addObject:[LirauNarrativeSharingLorauaDynamicItem discoveryFeedLorauaModelWithDictionary:dictionary]];
        }
    }
    return [models copy];
}

- (NSArray *)contentCurationLorauaArrayPayloadFromData:(id)data {
    if ([data isKindOfClass:NSArray.class]) {
        return data;
    }
    if (![data isKindOfClass:NSDictionary.class]) {
        return @[];
    }

    NSDictionary *dictionary = (NSDictionary *)data;
    for (NSString *key in [LirauEncryptionLorauaText contentCurationLorauaListContainerKeys]) {
        id value = dictionary[key];
        if ([value isKindOfClass:NSArray.class]) {
            return value;
        }
    }
    return @[];
}

- (NSString *)appIndexingLorauaBundleIdentifier {
    return [LirauEncryptionLorauaText appIndexingLorauaAppKey];
}

- (NSString *)sessionTokenLoraua {
    NSString *token = [NSUserDefaults.standardUserDefaults objectForKey:[LirauEncryptionLorauaText pointSystemLorauaSessionTokenStorageKey]];
    return [token isKindOfClass:NSString.class] ? token : @"";
}

- (BOOL)statusIndicatorLorauaIsSuccessCode:(NSString *)code {
    return [code isEqualToString:[LirauEncryptionLorauaText statusIndicatorLorauaPrimarySuccessCode]] || [code isEqualToString:[LirauEncryptionLorauaText statusIndicatorLorauaSecondarySuccessCode]];
}

- (NSString *)maskedSessionTokenLoraua {
    NSString *token = [self sessionTokenLoraua];
    if (token.length == 0) {
        return @"<empty>";
    }
    if (token.length <= 8) {
        return @"<masked>";
    }
    return [NSString stringWithFormat:@"%@...%@", [token substringToIndex:4], [token substringFromIndex:token.length - 4]];
}

- (NSString *)dataAnalyticsLorauaDebugJSONStringFromObject:(id)object {
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
