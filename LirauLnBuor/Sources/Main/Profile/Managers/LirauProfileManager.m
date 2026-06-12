#import "LirauProfileManager.h"
#import "LirauCipherText.h"

static NSString *LirauProfileBaseURLString(void) { return [LirauCipherText backendBaseURL]; }
static NSString *LirauProfileUserDetailPath(void) { return [LirauCipherText userDetailPath]; }

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
        configuration.timeoutIntervalForRequest = 30;
        configuration.timeoutIntervalForResource = 30;
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (void)loadProfileContentWithCompletion:(LirauProfileContentCompletion)completion {
    LirauProfileContent *localContent = [self localContent];
    NSString *userID = [self remoteUserIDFromLocalUser:localContent.user];
    if (userID.length == 0) {
        NSError *error = [NSError errorWithDomain:@"LirauProfile" code:-4 userInfo:@{NSLocalizedDescriptionKey: @"Missing current user ID for profile detail request."}];
        completion(localContent, error, YES, NO);
        return;
    }

    NSDictionary *parameters = @{@"privacyProtectionLoraua": userID};
    [self requestPath:LirauProfileUserDetailPath() parameters:parameters completion:^(id _Nullable data, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || ![data isKindOfClass:NSDictionary.class]) {
                completion(localContent, error, YES, YES);
                return;
            }

            NSDictionary *dictionary = (NSDictionary *)data;
            [localContent.user mergeRemoteDictionary:dictionary];
            NSArray *remotePosts = [self postsFromRemoteUserDictionary:dictionary fallbackAuthor:localContent.user.displayName];
            if ([dictionary[@"cloudHostingLoraua"] isKindOfClass:NSArray.class]) {
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
    NSString *currentEmail = [defaults stringForKey:[LirauCipherText currentEmailStorageKey]];
    if (currentEmail.length == 0) {
        return [LirauProfileUser testUser];
    }

    NSData *usersData = [defaults dataForKey:[LirauCipherText registeredUsersStorageKey]];
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

- (NSString *)remoteUserIDFromLocalUser:(LirauProfileUser *)user {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    id storedUserID = [defaults objectForKey:[LirauCipherText userIDStorageKey]];
    NSString *storedUserIDString = @"";
    if ([storedUserID isKindOfClass:NSString.class]) {
        storedUserIDString = (NSString *)storedUserID;
    } else if ([storedUserID respondsToSelector:@selector(stringValue)]) {
        storedUserIDString = [storedUserID stringValue];
    }
    if (storedUserIDString.length > 0) {
        return storedUserIDString;
    }

    NSString *localUserID = user.userID ?: @"";
    if (localUserID.length > 0 && ![localUserID hasPrefix:@"lirau_"]) {
        return localUserID;
    }
    return @"";
}

- (void)requestPath:(NSString *)path
         parameters:(NSDictionary *)parameters
         completion:(void (^)(id _Nullable data, NSError *_Nullable error))completion {
    NSURL *url = [NSURL URLWithString:[LirauProfileBaseURLString() stringByAppendingString:path]];
    if (!url) {
        completion(nil, [NSError errorWithDomain:@"LirauProfile" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid profile endpoint."}]);
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
    NSLog(@"LiraU API Request Profile: url=%@ params=%@ token=%@", url.absoluteString, [self debugJSONStringFromObject:parameters], [self maskedSessionTokenLoraua]);

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
        NSString *code = [NSString stringWithFormat:@"%@", dictionary[[LirauCipherText responseCodeKey]] ?: dictionary[[LirauCipherText responseStatusKey]] ?: @""];
        NSLog(@"LiraU API Parsed Profile: path=%@ code=%@ data=%@", path, code, [self debugJSONStringFromObject:dictionary[[LirauCipherText responseDataKey]]]);
        if (![self isSuccessCode:code]) {
            completion(nil, [NSError errorWithDomain:@"LirauProfile" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Profile request did not return success code."}]);
            return;
        }
        completion(dictionary[[LirauCipherText responseDataKey]], nil);
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
