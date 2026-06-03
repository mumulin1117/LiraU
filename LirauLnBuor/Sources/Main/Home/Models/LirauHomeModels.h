#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LirauHomeUserRecommendation : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatarURLString;
@property (nonatomic, copy) NSString *brief;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)mockWithName:(NSString *)name brief:(NSString *)brief;

@end

@interface LirauHomeDynamicItem : NSObject

@property (nonatomic, copy) NSString *dynamicId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imageURLString;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAvatarURLString;
@property (nonatomic, assign) NSInteger praiseCount;
@property (nonatomic, assign) NSInteger storeCount;
@property (nonatomic, assign) NSInteger commentCount;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)mockWithTitle:(NSString *)title content:(NSString *)content;

@end

@interface LirauHomeContent : NSObject

@property (nonatomic, copy) NSArray<LirauHomeUserRecommendation *> *recommendations;
@property (nonatomic, copy) NSArray<LirauHomeDynamicItem *> *talkShowItems;
@property (nonatomic, copy) NSArray<LirauHomeDynamicItem *> *wordBitsItems;

+ (instancetype)mockContent;

@end

NS_ASSUME_NONNULL_END
