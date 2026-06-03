#import "LirauVideoManager.h"

static NSString *const LirauVideoBaseURLString = @"http://a1d2f4s6g8h9j3k5.shop/backtwo";
static NSString *const LirauVideoDynamicListPath = @"/godoacxwlytpcwtz/btuwf";
static NSString *const LirauVideoSuccessCode = @"0000";

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
        configuration.timeoutIntervalForRequest = 8;
        configuration.timeoutIntervalForResource = 12;
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
    [self requestPath:LirauVideoDynamicListPath parameters:parameters completion:^(id _Nullable data, NSError *_Nullable error) {
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
    NSURL *url = [NSURL URLWithString:[LirauVideoBaseURLString stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauVideo" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid video endpoint."}]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        NSError *jsonError = nil;
        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
        if (jsonError || ![json isKindOfClass:NSDictionary.class]) {
            completion(nil, jsonError ?: [NSError errorWithDomain:@"LirauVideo" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid video response."}]);
            return;
        }
        NSDictionary *dictionary = (NSDictionary *)json;
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[@"code"] ?: dictionary[@"status"] ?: @""];
        if (![code isEqualToString:LirauVideoSuccessCode]) {
            completion(nil, [NSError errorWithDomain:@"LirauVideo" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Video request did not return success code 0000."}]);
            return;
        }
        completion(dictionary[@"data"], nil);
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
    for (NSString *key in @[@"list", @"records", @"rows", @"data"]) {
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
    return NSBundle.mainBundle.bundleIdentifier ?: @"com.lirau.lnbuor";
}

@end
