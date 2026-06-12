#import "LirauHomeManager.h"
#import "LirauCipherText.h"

static NSString *LirauHomeBaseURLString(void) { return [LirauCipherText backendBaseURL]; }
static NSString *LirauHomeUserIndexPath(void) { return [LirauCipherText userIndexPath]; }
static NSString *LirauHomeDynamicListPath(void) { return [LirauCipherText dynamicListPath]; }

@interface LirauHomeManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LirauHomeManager

+ (instancetype)sharedManager {
    static LirauHomeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LirauHomeManager alloc] init];
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

- (void)loadHomeContentWithCompletion:(LirauHomeContentCompletion)completion {
    dispatch_group_t group = dispatch_group_create();
    __block NSArray<LirauHomeUserRecommendation *> *recommendations = @[];
    __block NSArray<LirauHomeDynamicItem *> *talkShow = @[];
    __block NSArray<LirauHomeDynamicItem *> *wordBits = @[];
    __block NSError *lastError = nil;

    dispatch_group_enter(group);
    [self requestPath:LirauHomeUserIndexPath()
           parameters:@{@"culturalImmersionLoraua": [self LiruaBoundleIDD]}
           completion:^(id _Nullable data, NSError *_Nullable error) {
        if (error) {
            lastError = error;
        } else {
            recommendations = [self parseRecommendationsFromData:data];
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self requestPath:LirauHomeDynamicListPath()
           parameters:@{
               @"globalConnectivityLoraua": [self LiruaBoundleIDD],
               @"languageJourneyLoraua": @5,
               @"microLearningLoraua": @2,
               @"audioStreamingLoraua": @1,
               @"userEngagementLoraua": @10
           }
           completion:^(id _Nullable data, NSError *_Nullable error) {
        if (error) {
            lastError = error;
        } else {
            talkShow = [self parseDynamicsFromData:data];
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_enter(group);
    [self requestPath:LirauHomeDynamicListPath()
           parameters:@{
               @"globalConnectivityLoraua": [self LiruaBoundleIDD],
               @"languageJourneyLoraua": @4,
               @"audioStreamingLoraua": @1,
               @"userEngagementLoraua": @10
           }
           completion:^(id _Nullable data, NSError *_Nullable error) {
        if (error) {
            lastError = error;
        } else {
            wordBits = [self parseDynamicsFromData:data];
        }
        dispatch_group_leave(group);
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (recommendations.count == 0 && talkShow.count == 0 && wordBits.count == 0) {
            LirauHomeContent *fallback = [LirauHomeContent mockContent];
            completion(fallback, lastError, YES);
            return;
        }

        LirauHomeContent *content = [[LirauHomeContent alloc] init];
        LirauHomeContent *mockContent = [LirauHomeContent mockContent];
        content.recommendations = recommendations.count > 0 ? recommendations : mockContent.recommendations;
        content.talkShowItems = talkShow.count > 0 ? talkShow : mockContent.talkShowItems;
        content.wordBitsItems = wordBits.count > 0 ? wordBits : mockContent.wordBitsItems;
        completion(content, lastError, recommendations.count == 0 || talkShow.count == 0 || wordBits.count == 0);
    });
}

- (void)requestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauHomeBaseURLString() stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauHome" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid home endpoint."}]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = [LirauCipherText httpPostMethod];
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [request setValue:[LirauCipherText jsonMimeType] forHTTPHeaderField:[LirauCipherText contentTypeHeader]];
    [request setValue:[LirauCipherText jsonMimeType] forHTTPHeaderField:[LirauCipherText acceptHeader]];
    [request setValue:[LirauCipherText appKey] forHTTPHeaderField:[LirauCipherText keyHeader]];
    [request setValue:[self sessionTokenLoraua] forHTTPHeaderField:[LirauCipherText tokenHeader]];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSLog(@"LiraU API Request Home: url=%@ params=%@ token=%@", url.absoluteString, [self debugJSONStringFromObject:parameters], [self maskedSessionTokenLoraua]);

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"LiraU API Failure Home: url=%@ error=%@", url.absoluteString, error.localizedDescription);
            completion(nil, error);
            return;
        }

        NSInteger statusCode = [response isKindOfClass:NSHTTPURLResponse.class] ? ((NSHTTPURLResponse *)response).statusCode : -1;
        NSString *rawText = data.length > 0 ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"<empty response>";
        NSLog(@"LiraU API Response Home: url=%@ status=%ld raw=%@", url.absoluteString, (long)statusCode, rawText ?: @"<non-utf8 response>");

        NSError *jsonError = nil;
        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
        if (jsonError || ![json isKindOfClass:NSDictionary.class]) {
            NSLog(@"LiraU API Invalid Home: url=%@ error=%@", url.absoluteString, jsonError.localizedDescription ?: @"Invalid home response.");
            completion(nil, jsonError ?: [NSError errorWithDomain:@"LirauHome" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid home response."}]);
            return;
        }

        NSDictionary *dictionary = (NSDictionary *)json;
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[[LirauCipherText responseCodeKey]] ?: dictionary[[LirauCipherText responseStatusKey]] ?: @""];
        NSLog(@"LiraU API Parsed Home: path=%@ code=%@ data=%@", path, code, [self debugJSONStringFromObject:dictionary[[LirauCipherText responseDataKey]]]);
        if (![self isSuccessCode:code]) {
            completion(nil, [NSError errorWithDomain:@"LirauHome" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Home request did not return success code."}]);
            return;
        }
        completion(dictionary[[LirauCipherText responseDataKey]], nil);
    }];
    [task resume];
}

- (NSArray<LirauHomeUserRecommendation *> *)parseRecommendationsFromData:(id)data {
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *dictionary in [self arrayPayloadFromData:data]) {
        if ([dictionary isKindOfClass:NSDictionary.class]) {
            [models addObject:[LirauHomeUserRecommendation modelWithDictionary:dictionary]];
        }
    }
    return [models copy];
}

- (NSArray<LirauHomeDynamicItem *> *)parseDynamicsFromData:(id)data {
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *dictionary in [self arrayPayloadFromData:data]) {
        if ([dictionary isKindOfClass:NSDictionary.class]) {
            [models addObject:[LirauHomeDynamicItem modelWithDictionary:dictionary]];
        }
    }
    return [models copy];
}

- (NSArray *)arrayPayloadFromData:(id)data {
    if ([data isKindOfClass:NSArray.class]) {
        return data;
    }
    if (![data isKindOfClass:NSDictionary.class]) {
        return @[];
    }

    NSDictionary *dictionary = (NSDictionary *)data;
    for (NSString *key in [LirauCipherText listContainerKeys]) {
        id value = dictionary[key];
        if ([value isKindOfClass:NSArray.class]) {
            return value;
        }
    }
    return @[];
}

- (NSString *)LiruaBoundleIDD {
    return [LirauCipherText appKey];
}

- (NSString *)sessionTokenLoraua {
    NSString *token = [NSUserDefaults.standardUserDefaults objectForKey:[LirauCipherText sessionTokenStorageKey]];
    return [token isKindOfClass:NSString.class] ? token : @"";
}

- (BOOL)isSuccessCode:(NSString *)code {
    return [code isEqualToString:[LirauCipherText primarySuccessCode]] || [code isEqualToString:[LirauCipherText secondarySuccessCode]];
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

- (NSString *)debugJSONStringFromObject:(id)object {
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
