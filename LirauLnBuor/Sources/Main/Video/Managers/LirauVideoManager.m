#import "LirauVideoManager.h"
#import "LirauCipherText.h"

static NSString *LirauVideoBaseURLString(void) { return [LirauCipherText backendBaseURL]; }
static NSString *LirauVideoDynamicListPath(void) { return [LirauCipherText dynamicListPath]; }

@interface LirauVideoManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LirauVideoManager

+ (instancetype)sharedManager {
    static LirauVideoManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LirauVideoManager alloc] init];
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

- (void)loadVideosWithCategory:(LirauVideoCategory)category
                          page:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                    completion:(LirauVideoListCompletion)completion {
    NSDictionary *parameters = @{
        @"globalConnectivityLoraua": [self bundleIdentifier],
        @"audioStreamingLoraua": @(MAX(page, 1)),
        @"userEngagementLoraua": @(MAX(pageSize, 1))
    };
    [self requestPath:LirauVideoDynamicListPath() parameters:parameters completion:^(id _Nullable data, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completion([self mockItems], error, NO, YES);
                return;
            }
            NSArray<LirauVideoItem *> *items = [self parseVideoItemsFromData:data];
            if (items.count == 0 && page == 1) {
                completion([self mockItems], nil, NO, YES);
                return;
            }
            completion(items, nil, items.count >= pageSize, NO);
        });
    }];
}

- (void)requestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauVideoBaseURLString() stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauVideo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid video endpoint."}]);
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
    NSLog(@"LiraU API Request Video: url=%@ params=%@ token=%@", url.absoluteString, [self debugJSONStringFromObject:parameters], [self maskedSessionTokenLoraua]);

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
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[[LirauCipherText responseCodeKey]] ?: dictionary[[LirauCipherText responseStatusKey]] ?: @""];
        NSLog(@"LiraU API Parsed Video: path=%@ code=%@ data=%@", path, code, [self debugJSONStringFromObject:dictionary[[LirauCipherText responseDataKey]]]);
        if (![self isSuccessCode:code]) {
            completion(nil, [NSError errorWithDomain:@"LirauVideo" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Video request did not return success code."}]);
            return;
        }
        completion(dictionary[[LirauCipherText responseDataKey]], nil);
    }];
    [task resume];
}

- (NSArray<LirauVideoItem *> *)parseVideoItemsFromData:(id)data {
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dictionary in [self arrayPayloadFromData:data]) {
        if (![dictionary isKindOfClass:NSDictionary.class]) {
            continue;
        }
        LirauVideoItem *item = [LirauVideoItem modelWithDictionary:dictionary];
        if (item.videoCoverURLString.length > 0) {
            [items addObject:item];
        }
    }
    return [items copy];
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

- (NSArray<LirauVideoItem *> *)mockItems {
    return @[
        [LirauVideoItem mockWithTitle:@"Sunday afternoons are for creating" userName:@"Luna Sprig"],
        [LirauVideoItem mockWithTitle:@"Accent notes from a quiet study break" userName:@"Sunny Daze"]
    ];
}

- (NSString *)bundleIdentifier {
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
