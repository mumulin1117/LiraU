#import "LirauCipherText.h"

static const unsigned char LirauCipherTextKey = 45;

#define LIRAU_TEXT(...) [LirauCipherText lirauTextWithCipherBytes:@[__VA_ARGS__]]

@implementation LirauCipherText

+ (NSString *)lirauTextWithCipherBytes:(NSArray<NSNumber *> *)bytes {
    NSMutableData *data = [NSMutableData dataWithCapacity:bytes.count];
    for (NSNumber *number in bytes) {
        unsigned char encoded = number.unsignedCharValue;
        unsigned char decoded = encoded ^ LirauCipherTextKey;
        [data appendBytes:&decoded length:sizeof(decoded)];
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
}

+ (NSString *)backendBaseURL {
    return LIRAU_TEXT(@69, @89, @89, @93, @23, @2, @2, @76, @28, @73, @31, @75, @25, @94, @27, @74, @21, @69, @20, @71, @30, @70, @24, @3, @94, @69, @66, @93, @2, @79, @76, @78, @70, @89, @90, @66);
}

+ (NSString *)appKey {
    return LIRAU_TEXT(@21, @28, @31, @27, @27, @21, @25, @30);
}

+ (NSString *)httpPostMethod {
    return LIRAU_TEXT(@125, @98, @126, @121);
}

+ (NSString *)jsonMimeType {
    return LIRAU_TEXT(@76, @93, @93, @65, @68, @78, @76, @89, @68, @66, @67, @2, @71, @94, @66, @67);
}

+ (NSString *)contentTypeHeader {
    return LIRAU_TEXT(@110, @66, @67, @89, @72, @67, @89, @0, @121, @84, @93, @72);
}

+ (NSString *)acceptHeader {
    return LIRAU_TEXT(@108, @78, @78, @72, @93, @89);
}

+ (NSString *)keyHeader {
    return LIRAU_TEXT(@70, @72, @84);
}

+ (NSString *)tokenHeader {
    return LIRAU_TEXT(@89, @66, @70, @72, @67);
}

+ (NSString *)primarySuccessCode {
    return LIRAU_TEXT(@29, @29, @29, @29);
}

+ (NSString *)secondarySuccessCode {
    return LIRAU_TEXT(@31, @29, @29, @29, @29, @29);
}

+ (NSString *)emailAuthPath {
    return LIRAU_TEXT(@2, @76, @85, @69, @78, @84, @64, @79, @87, @2, @75, @68, @94, @90, @66, @72, @94, @71, @76, @68, @73);
}

+ (NSString *)userIndexPath {
    return LIRAU_TEXT(@2, @69, @75, @64, @79, @70, @79, @66, @92, @87, @87, @2, @84, @65, @91, @75, @89);
}

+ (NSString *)dynamicListPath {
    return LIRAU_TEXT(@2, @74, @66, @73, @66, @76, @78, @85, @90, @65, @84, @89, @93, @78, @90, @89, @87, @2, @79, @89, @88, @90, @75);
}

+ (NSString *)userDetailPath {
    return LIRAU_TEXT(@2, @78, @76, @89, @94, @85, @87, @2, @72, @93, @91, @90, @70, @89, @78);
}

+ (NSString *)sessionTokenStorageKey {
    return LIRAU_TEXT(@93, @66, @68, @67, @89, @126, @84, @94, @89, @72, @64, @97, @66, @95, @76, @88, @76);
}

+ (NSString *)userIDStorageKey {
    return LIRAU_TEXT(@95, @72, @94, @93, @66, @67, @94, @68, @91, @72, @105, @72, @94, @68, @74, @67, @97, @66, @95, @76, @88, @76);
}

+ (NSString *)currentEmailStorageKey {
    return LIRAU_TEXT(@65, @68, @95, @76, @88, @114, @78, @88, @95, @95, @72, @67, @89, @114, @72, @64, @76, @68, @65);
}

+ (NSString *)registeredUsersStorageKey {
    return LIRAU_TEXT(@65, @68, @95, @76, @88, @114, @95, @72, @74, @68, @94, @89, @72, @95, @72, @73, @114, @88, @94, @72, @95, @94);
}

+ (NSString *)responseCodeKey {
    return LIRAU_TEXT(@78, @66, @73, @72);
}

+ (NSString *)responseStatusKey {
    return LIRAU_TEXT(@94, @89, @76, @89, @88, @94);
}

+ (NSString *)responseDataKey {
    return LIRAU_TEXT(@73, @76, @89, @76);
}

+ (NSArray<NSString *> *)listContainerKeys {
    return @[
        LIRAU_TEXT(@65, @68, @94, @89),
        LIRAU_TEXT(@95, @72, @78, @66, @95, @73, @94),
        LIRAU_TEXT(@95, @66, @90, @94),
        [self responseDataKey]
    ];
}

+ (NSString *)webBaseHashURL {
    return LIRAU_TEXT(@69, @89, @89, @93, @23, @2, @2, @76, @28, @73, @31, @75, @25, @94, @27, @74, @21, @69, @20, @71, @30, @70, @24, @3, @94, @69, @66, @93, @2, @14, @2);
}

+ (NSString *)webAIExpertPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @108, @100, @72, @85, @93, @72, @95, @89, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webRepositoryPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @95, @72, @93, @66, @94, @68, @89, @66, @95, @84, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webDynamicDetailPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @105, @84, @67, @76, @64, @68, @78, @105, @72, @89, @76, @68, @65, @94, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webPostArticlePath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @68, @94, @94, @88, @72, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webPostVideoPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @93, @66, @94, @89, @123, @68, @73, @72, @66, @94, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webLearnerProfilePath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @69, @66, @64, @72, @93, @76, @74, @72, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webReportPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @95, @72, @93, @66, @95, @89, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webMessagesPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @68, @67, @75, @66, @95, @64, @76, @89, @68, @66, @67, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webEditProfilePath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @104, @73, @68, @89, @105, @76, @89, @76, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webRelationListPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @76, @89, @89, @72, @67, @89, @68, @66, @67, @97, @68, @94, @89, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webWalletPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @90, @76, @65, @65, @72, @89, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webSettingsPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @126, @72, @89, @120, @93, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webAgreementPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @108, @74, @95, @72, @72, @64, @72, @67, @89, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)webPrivateChatPath {
    return LIRAU_TEXT(@93, @76, @74, @72, @94, @2, @93, @95, @68, @91, @76, @89, @72, @110, @69, @76, @89, @2, @68, @67, @73, @72, @85);
}

+ (NSString *)queryCurrentKey {
    return LIRAU_TEXT(@78, @88, @95, @95, @72, @67, @89);
}

+ (NSString *)queryDynamicIDKey {
    return LIRAU_TEXT(@73, @84, @67, @76, @64, @68, @78, @100, @73);
}

+ (NSString *)queryUserIDKey {
    return LIRAU_TEXT(@88, @94, @72, @95, @100, @73);
}

+ (NSString *)queryTypeKey {
    return LIRAU_TEXT(@89, @84, @93, @72);
}

+ (NSString *)queryCallVideoKey {
    return LIRAU_TEXT(@110, @76, @65, @65, @123, @68, @73, @72, @66);
}

+ (NSString *)queryAppIDKey {
    return LIRAU_TEXT(@76, @93, @93, @100, @105);
}

+ (NSString *)bridgePurchaseName {
    return [self sessionTokenStorageKey];
}

+ (NSString *)bridgePurchaseSuccessName {
    return LIRAU_TEXT(@65, @72, @76, @73, @72, @95, @79, @66, @76, @95, @73, @97, @66, @95, @76, @88, @76);
}

+ (NSString *)bridgeOpenPathName {
    return LIRAU_TEXT(@73, @76, @68, @65, @84, @124, @88, @72, @94, @89, @97, @66, @95, @76, @88, @76);
}

+ (NSString *)bridgeCloseName {
    return LIRAU_TEXT(@94, @72, @76, @94, @66, @67, @76, @65, @104, @91, @72, @67, @89, @97, @66, @95, @76, @88, @76);
}

+ (NSString *)bridgeLogoutName {
    return LIRAU_TEXT(@65, @68, @64, @68, @89, @72, @73, @121, @68, @64, @72, @98, @75, @75, @72, @95, @97, @66, @95, @76, @88, @76);
}

@end

#undef LIRAU_TEXT
