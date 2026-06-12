#import "LirauVSnippetLorauaManager.h"
#import "LirauEncryptionLorauaText.h"

static NSString *LirauVideoSnippetLorauaBaseURLString(void) { return [LirauEncryptionLorauaText backendArchitectureLorauaBaseURL]; }
static NSString *LirauVideoSnippetLorauaDynamicListPath(void) { return [LirauEncryptionLorauaText narrativeSharingLorauaDynamicListPath]; }

@interface LirauVSnippetLorauaManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LirauVSnippetLorauaManager

+ (instancetype)sharedVideoSnippetLorauaManager {
    static LirauVSnippetLorauaManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LirauVSnippetLorauaManager alloc] init];
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

- (void)loadVideoSnippetLorauaItemsWithCategory:(LirauVideoSnippetLorauaCategory)category
                          page:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                    completion:(LirauVideoSnippetLorauaListCompletion)completion {
    NSDictionary *parameters = @{
        @"globalConnectivityLoraua": [self appIndexingLorauaBundleIdentifier],
        @"audioStreamingLoraua": @(MAX(page, 1)),
        @"userEngagementLoraua": @(MAX(pageSize, 1))
    };
    [self requestVideoSnippetLorauaPath:LirauVideoSnippetLorauaDynamicListPath() parameters:parameters completion:^(id _Nullable data, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completion([self mockVideoSnippetLorauaItems], error, NO, YES);
                return;
            }
            NSArray<LirauVSnippetLorauaItem *> *items = [self parseVideoSnippetLorauaItemsFromData:data];
            if (items.count == 0 && page == 1) {
                completion([self mockVideoSnippetLorauaItems], nil, NO, YES);
                return;
            }
            completion(items, nil, items.count >= pageSize, NO);
        });
    }];
}

- (void)requestVideoSnippetLorauaPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauVideoSnippetLorauaBaseURLString() stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauVideo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid video endpoint."}]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = [LirauEncryptionLorauaText restfulAPILorauaPostMethod];
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [request setValue:[LirauEncryptionLorauaText apiFirstLorauaJSONMimeType] forHTTPHeaderField:[LirauEncryptionLorauaText apiFirstLorauaContentTypeHeader]];
    [request setValue:[LirauEncryptionLorauaText apiFirstLorauaJSONMimeType] forHTTPHeaderField:[LirauEncryptionLorauaText restfulAPILorauaAcceptHeader]];
    [request setValue:[LirauEncryptionLorauaText appIndexingLorauaAppKey] forHTTPHeaderField:[LirauEncryptionLorauaText apiFirstLorauaKeyHeader]];
    [request setValue:[self videoSnippetLorauaSessionToken] forHTTPHeaderField:[LirauEncryptionLorauaText pointSystemLorauaTokenHeader]];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSLog(@"LiraU API Request Video: url=%@ params=%@ token=%@", url.absoluteString, [self videoSnippetLorauaDebugJSONStringFromObject:parameters], [self videoSnippetLorauaMaskedSessionToken]);

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"LiraU API Failure Video: url=%@ error=%@", url.absoluteString, error.localizedDescription);
            completion(nil, error);
            return;
        }
        NSInteger statusCode = [response isKindOfClass:NSHTTPURLResponse.class] ? ((NSHTTPURLResponse *)response).statusCode : -1;
        NSString *rawText = data.length > 0 ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"<empty response>";
        NSLog(@"LiraU API Response Video: url=%@ status=%ld raw=%@", url.absoluteString, (long)statusCode, rawText ?: @"<non-utf8 response>");

        NSError *jsonError = nil;
        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
        if (jsonError || ![json isKindOfClass:NSDictionary.class]) {
            NSLog(@"LiraU API Invalid Video: url=%@ error=%@", url.absoluteString, jsonError.localizedDescription ?: @"Invalid video response.");
            completion(nil, jsonError ?: [NSError errorWithDomain:@"LirauVideo" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid video response."}]);
            return;
        }
        NSDictionary *dictionary = (NSDictionary *)json;
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[[LirauEncryptionLorauaText restfulAPILorauaResponseCodeKey]] ?: dictionary[[LirauEncryptionLorauaText statusIndicatorLorauaResponseStatusKey]] ?: @""];
        NSLog(@"LiraU API Parsed Video: path=%@ code=%@ data=%@", path, code, [self videoSnippetLorauaDebugJSONStringFromObject:dictionary[[LirauEncryptionLorauaText dataAnalyticsLorauaResponseDataKey]]]);
        if (![self videoSnippetLorauaIsSuccessCode:code]) {
            completion(nil, [NSError errorWithDomain:@"LirauVideo" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Video request did not return success code."}]);
            return;
        }
        completion(dictionary[[LirauEncryptionLorauaText dataAnalyticsLorauaResponseDataKey]], nil);
    }];
    [task resume];
}

- (NSArray<LirauVSnippetLorauaItem *> *)parseVideoSnippetLorauaItemsFromData:(id)data {
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dictionary in [self videoSnippetLorauaArrayPayloadFromData:data]) {
        if (![dictionary isKindOfClass:NSDictionary.class]) {
            continue;
        }
        LirauVSnippetLorauaItem *item = [LirauVSnippetLorauaItem videoSnippetLorauaModelWithDictionary:dictionary];
        if (item.videoCoverURLString.length > 0) {
            [items addObject:item];
        }
    }
    return [items copy];
}

- (NSArray *)videoSnippetLorauaArrayPayloadFromData:(id)data {
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

- (NSArray<LirauVSnippetLorauaItem *> *)mockVideoSnippetLorauaItems {
    return @[
        [LirauVSnippetLorauaItem mockVideoSnippetLorauaItemWithTitle:@"Sunday afternoons are for creating" userName:@"Luna Sprig"],
        [LirauVSnippetLorauaItem mockVideoSnippetLorauaItemWithTitle:@"Accent notes from a quiet study break" userName:@"Sunny Daze"]
    ];
}

- (NSString *)appIndexingLorauaBundleIdentifier {
    return [LirauEncryptionLorauaText appIndexingLorauaAppKey];
}

- (NSString *)videoSnippetLorauaSessionToken {
    NSString *token = [NSUserDefaults.standardUserDefaults objectForKey:[LirauEncryptionLorauaText pointSystemLorauaSessionTokenStorageKey]];
    return [token isKindOfClass:NSString.class] ? token : @"";
}

- (BOOL)videoSnippetLorauaIsSuccessCode:(NSString *)code {
    return [code isEqualToString:[LirauEncryptionLorauaText statusIndicatorLorauaPrimarySuccessCode]] || [code isEqualToString:[LirauEncryptionLorauaText statusIndicatorLorauaSecondarySuccessCode]];
}

- (NSString *)videoSnippetLorauaMaskedSessionToken {
    NSString *token = [self videoSnippetLorauaSessionToken];
    if (token.length == 0) {
        return @"<empty>";
    }
    if (token.length <= 8) {
        return @"<masked>";
    }
    return [NSString stringWithFormat:@"%@...%@", [token substringToIndex:4], [token substringFromIndex:token.length - 4]];
}

- (NSString *)videoSnippetLorauaDebugJSONStringFromObject:(id)object {
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
