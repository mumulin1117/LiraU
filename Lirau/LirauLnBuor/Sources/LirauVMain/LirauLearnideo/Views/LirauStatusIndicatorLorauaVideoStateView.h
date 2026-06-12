#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LirauStatusIndicatorLorauaVideoStateView : UIView

@property (nonatomic, copy, nullable) void (^statusIndicatorLorauaRetryHandler)(void);

- (void)showStatusIndicatorLorauaLoading;
- (void)showStatusIndicatorLorauaMessage:(NSString *)message retryVisible:(BOOL)retryVisible;
- (void)hideStatusIndicatorLorauaState;

@end

NS_ASSUME_NONNULL_END
