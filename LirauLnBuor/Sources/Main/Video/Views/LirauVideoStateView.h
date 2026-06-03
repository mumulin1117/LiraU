#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LirauVideoStateView : UIView

@property (nonatomic, copy, nullable) void (^retryHandler)(void);

- (void)showLoading;
- (void)showMessage:(NSString *)message retryVisible:(BOOL)retryVisible;
- (void)hideState;

@end

NS_ASSUME_NONNULL_END
