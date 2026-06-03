#import "LirauProfileManager.h"

static NSString *const LirauProfileBaseURLString = @"http://a1d2f4s6g8h9j3k5.shop/backtwo";
static NSString *const LirauProfileCurrentUserPath = @"/gnxdnzmqesz/wkjqs";
static NSString *const LirauProfileSuccessCode = @"0000";

@interface LirauProfileManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LirauProfileManager

+ (instancetype)sharedManager {
    static LirauProfileManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LirauProfileManager alloc] init];
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

- (void)loadProfileContentWithCompletion:(LirauProfileContentCompletion)completion {
    LirauProfileContent *localContent = [self localContent];
    [self requestPath:LirauProfileCurrentUserPath parameters:@{} completion:^(id _Nullable data, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || ![data isKindOfClass:NSDictionary.class]) {
                completion(localContent, error, YES, YES);
                return;
            }

            NSDictionary *dictionary = (NSDictionary *)data;
            [localContent.user mergeRemoteDictionary:dictionary];
            NSArray *remotePosts = [self postsFromRemoteUserDictionary:dictionary fallbackAuthor:localContent.user.displayName];
            if (remotePosts.count > 0) {
                localContent.posts = remotePosts;
                localContent.user.postCount = MAX(localContent.user.postCount, remotePosts.count);
            }
            completion(localContent, nil, NO, YES);
        });
    }];
}

- (LirauProfileContent *)localContent {
    LirauProfileContent *content = [[LirauProfileContent alloc] init];
    content.user = [self localCurrentUser];
    content.posts = [LirauProfileContent mockContent].posts;
    return content;
}

- (LirauProfileUser *)localCurrentUser {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSString *currentEmail = [defaults stringForKey:@"lirau_current_email"];
    if (currentEmail.length == 0) {
        return [LirauProfileUser testUser];
    }

    NSData *usersData = [defaults dataForKey:@"lirau_registered_users"];
    if (usersData.length > 0) {
        NSError *error = nil;
        NSDictionary *users = [NSJSONSerialization JSONObjectWithData:usersData options:0 error:&error];
        if ([users isKindOfClass:NSDictionary.class]) {
            NSDictionary *userDictionary = users[currentEmail];
            if ([userDictionary isKindOfClass:NSDictionary.class]) {
                return [LirauProfileUser localUserWithDictionary:userDictionary email:currentEmail];
            }
        }
    }

    if ([currentEmail isEqualToString:@"lariau@gmail.com"]) {
        return [LirauProfileUser testUser];
    }
    return [LirauProfileUser localUserWithDictionary:@{@"email": currentEmail, @"displayName": @"LiraU Learner"} email:currentEmail];
}

- (void)requestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauProfileBaseURLString stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauProfile" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid profile endpoint."}]);
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
            completion(nil, jsonError ?: [NSError errorWithDomain:@"LirauProfile" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid profile response."}]);
            return;
        }

        NSDictionary *dictionary = (NSDictionary *)json;
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[@"code"] ?: dictionary[@"status"] ?: @""];
        if (![code isEqualToString:LirauProfileSuccessCode]) {
            completion(nil, [NSError errorWithDomain:@"LirauProfile" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Profile request did not return success code 0000."}]);
            return;
        }
        completion(dictionary[@"data"], nil);
    }];
    [task resume];
}

- (NSArray<LirauProfilePost *> *)postsFromRemoteUserDictionary:(NSDictionary *)dictionary fallbackAuthor:(NSString *)fallbackAuthor {
    id list = dictionary[@"cloudHostingLoraua"];
    if (![list isKindOfClass:NSArray.class]) {
        return @[];
    }

    NSMutableArray<LirauProfilePost *> *posts = [NSMutableArray array];
    for (NSDictionary *postDictionary in (NSArray *)list) {
        if ([postDictionary isKindOfClass:NSDictionary.class]) {
            [posts addObject:[LirauProfilePost modelWithDictionary:postDictionary fallbackAuthor:fallbackAuthor]];
        }
    }
    return [posts copy];
}

@end
