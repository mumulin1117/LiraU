#import "LirauHomeManager.h"

static NSString *const LirauHomeBaseURLString = @"http://www.modernlifestylehub99globalmarket.shop";
static NSString *const LirauHomeUserIndexPath = @"/hfmbkboqzz/ylvft";
static NSString *const LirauHomeDynamicListPath = @"/godoacxwlytpcwtz/btuwf";
static NSString *const LirauHomeSuccessCode = @"0000";

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
        configuration.timeoutIntervalForRequest = 8;
        configuration.timeoutIntervalForResource = 12;
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (void)loadHomeContentWithCompletion:(LirauHomeContentCompletion)completion {
    dispatch_group_t group = dispatch_group_create();
    __block NSArray<LirauHomeUserRecommendation *> *recommendations = @[];
    __block NSArray<LirauHomeDynamicItem *> *wordBits = @[];
    __block NSError *lastError = nil;

    dispatch_group_enter(group);
    [self requestPath:LirauHomeUserIndexPath
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
    [self requestPath:LirauHomeDynamicListPath
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
        if (recommendations.count == 0 && wordBits.count == 0) {
            LirauHomeContent *fallback = [LirauHomeContent mockContent];
            completion(fallback, lastError, YES);
            return;
        }

        LirauHomeContent *content = [[LirauHomeContent alloc] init];
        LirauHomeContent *mockContent = [LirauHomeContent mockContent];
        content.recommendations = recommendations.count > 0 ? recommendations : mockContent.recommendations;
        content.wordBitsItems = wordBits.count > 0 ? wordBits : mockContent.wordBitsItems;
        content.talkShowItems = wordBits.count > 0 ? [wordBits subarrayWithRange:NSMakeRange(0, MIN(wordBits.count, 3))] : mockContent.talkShowItems;
        completion(content, lastError, recommendations.count == 0 || wordBits.count == 0);
    });
}

- (void)requestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauHomeBaseURLString stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauHome" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid home endpoint."}]);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"key" forHTTPHeaderField:@"81266843"];
    [request setValue:@"token" forHTTPHeaderField:@"Accept"];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        NSError *jsonError = nil;
        id json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;
        if (jsonError || ![json isKindOfClass:NSDictionary.class]) {
            completion(nil, jsonError ?: [NSError errorWithDomain:@"LirauHome" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid home response."}]);
            return;
        }

        NSDictionary *dictionary = (NSDictionary *)json;
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[@"code"] ?: dictionary[@"status"] ?: @""];
        if (![code isEqualToString:LirauHomeSuccessCode]) {
            completion(nil, [NSError errorWithDomain:@"LirauHome" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Home request did not return success code 0000."}]);
            return;
        }
        completion(dictionary[@"data"], nil);
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
    for (NSString *key in @[@"list", @"records", @"rows", @"data"]) {
        id value = dictionary[key];
        if ([value isKindOfClass:NSArray.class]) {
            return value;
        }
    }
    return @[];
}

- (NSString *)LiruaBoundleIDD {
    return  @"81266843";
}

@end
