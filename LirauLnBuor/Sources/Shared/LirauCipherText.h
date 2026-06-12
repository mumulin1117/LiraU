#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LirauCipherText : NSObject

+ (NSString *)lirauTextWithCipherBytes:(NSArray<NSNumber *> *)bytes;

+ (NSString *)backendBaseURL;
+ (NSString *)appKey;
+ (NSString *)httpPostMethod;
+ (NSString *)jsonMimeType;
+ (NSString *)contentTypeHeader;
+ (NSString *)acceptHeader;
+ (NSString *)keyHeader;
+ (NSString *)tokenHeader;
+ (NSString *)primarySuccessCode;
+ (NSString *)secondarySuccessCode;

+ (NSString *)emailAuthPath;
+ (NSString *)userIndexPath;
+ (NSString *)dynamicListPath;
+ (NSString *)userDetailPath;

+ (NSString *)sessionTokenStorageKey;
+ (NSString *)userIDStorageKey;
+ (NSString *)currentEmailStorageKey;
+ (NSString *)registeredUsersStorageKey;

+ (NSString *)responseCodeKey;
+ (NSString *)responseStatusKey;
+ (NSString *)responseDataKey;
+ (NSArray<NSString *> *)listContainerKeys;

+ (NSString *)webBaseHashURL;
+ (NSString *)webAIExpertPath;
+ (NSString *)webRepositoryPath;
+ (NSString *)webDynamicDetailPath;
+ (NSString *)webPostArticlePath;
+ (NSString *)webPostVideoPath;
+ (NSString *)webLearnerProfilePath;
+ (NSString *)webReportPath;
+ (NSString *)webMessagesPath;
+ (NSString *)webEditProfilePath;
+ (NSString *)webRelationListPath;
+ (NSString *)webWalletPath;
+ (NSString *)webSettingsPath;
+ (NSString *)webAgreementPath;
+ (NSString *)webPrivateChatPath;

+ (NSString *)queryCurrentKey;
+ (NSString *)queryDynamicIDKey;
+ (NSString *)queryUserIDKey;
+ (NSString *)queryTypeKey;
+ (NSString *)queryCallVideoKey;
+ (NSString *)queryAppIDKey;

+ (NSString *)bridgePurchaseName;
+ (NSString *)bridgePurchaseSuccessName;
+ (NSString *)bridgeOpenPathName;
+ (NSString *)bridgeCloseName;
+ (NSString *)bridgeLogoutName;

@end

NS_ASSUME_NONNULL_END
