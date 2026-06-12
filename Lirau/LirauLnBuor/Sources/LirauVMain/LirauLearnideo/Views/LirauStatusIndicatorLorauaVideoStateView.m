#import "LirauStatusIndicatorLorauaVideoStateView.h"

@interface LirauStatusIndicatorLorauaVideoStateView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation LirauStatusIndicatorLorauaVideoStateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildDiscoveryFeedLorauaView];
    }
    return self;
}

- (void)buildDiscoveryFeedLorauaView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor colorWithRed:0.11 green:0.10 blue:0.18 alpha:0.92];

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicatorView.color = UIColor.whiteColor;
    [self addSubview:self.indicatorView];

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.messageLabel.textColor = [UIColor colorWithWhite:1 alpha:0.72];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 0;
    [self addSubview:self.messageLabel];

    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.retryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.retryButton setTitle:@"Retry" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    self.retryButton.backgroundColor = [UIColor colorWithRed:0.72 green:0.24 blue:1 alpha:1];
    self.retryButton.layer.cornerRadius = 18;
    [self.retryButton addTarget:self action:@selector(didTapRetry) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.retryButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.indicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.indicatorView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-12],
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.indicatorView.bottomAnchor constant:12],
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:32],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-32],
        [self.retryButton.topAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:14],
        [self.retryButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.retryButton.widthAnchor constraintEqualToConstant:104],
        [self.retryButton.heightAnchor constraintEqualToConstant:36]
    ]];
}

- (void)showStatusIndicatorLorauaLoading {
    self.hidden = NO;
    self.messageLabel.text = @"Loading LiraU videos...";
    self.retryButton.hidden = YES;
    [self.indicatorView startAnimating];
}

- (void)showStatusIndicatorLorauaMessage:(NSString *)message retryVisible:(BOOL)retryVisible {
    self.hidden = NO;
    self.messageLabel.text = message;
    self.retryButton.hidden = !retryVisible;
    [self.indicatorView stopAnimating];
}

- (void)hideStatusIndicatorLorauaState {
    self.hidden = YES;
    [self.indicatorView stopAnimating];
}

- (void)didTapRetry {
    if (self.statusIndicatorLorauaRetryHandler) {
        self.statusIndicatorLorauaRetryHandler();
    }
}

@end
