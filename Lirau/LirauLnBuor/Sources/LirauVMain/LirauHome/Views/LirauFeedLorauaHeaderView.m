#import "LirauFeedLorauaHeaderView.h"

@interface LirauFeedLorauaHeaderView ()

@property (nonatomic, strong) UIImageView *waveImageView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIButton *notificationButton;

@end

@implementation LirauFeedLorauaHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildDiscoveryFeedLorauaView];
    }
    return self;
}

- (void)buildDiscoveryFeedLorauaView {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    _waveImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_home_header_wave"]];
    _waveImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _waveImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_waveImageView];

    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_home_logo_text"]];
    _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_logoImageView];

    _notificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _notificationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_notificationButton setBackgroundImage:[UIImage imageNamed:@"lira_home_notification_button"] forState:UIControlStateNormal];
    [_notificationButton setImage:[UIImage imageNamed:@"lira_home_notification_bell"] forState:UIControlStateNormal];
    [_notificationButton addTarget:self action:@selector(didTapNotificationSettingLorauaEntry) forControlEvents:UIControlEventTouchUpInside];
    _notificationButton.accessibilityLabel = @"LiraU notifications";
    [self addSubview:_notificationButton];

    [NSLayoutConstraint activateConstraints:@[
        [_waveImageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_waveImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_waveImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_waveImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

        [_logoImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [_logoImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:9],
        [_logoImageView.widthAnchor constraintEqualToConstant:81],
        [_logoImageView.heightAnchor constraintEqualToConstant:35],

        [_notificationButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [_notificationButton.centerYAnchor constraintEqualToAnchor:_logoImageView.centerYAnchor],
        [_notificationButton.widthAnchor constraintEqualToConstant:44],
        [_notificationButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)didTapNotificationSettingLorauaEntry {
    if (self.notificationHandler) {
        self.notificationHandler();
    }
}

@end
