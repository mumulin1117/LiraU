#import "LirauProfileWalletView.h"

@interface LirauProfileWalletView ()

@property (nonatomic, strong) UIImageView *coinImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation LirauProfileWalletView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.cornerRadius = 24;
    self.clipsToBounds = YES;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.name = @"lira_profile_wallet_gradient";
    gradient.colors = @[
        (__bridge id)[UIColor colorWithRed:0.772 green:0.369 blue:1 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.420 green:0.220 blue:1 alpha:1].CGColor
    ];
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(0.5, 1);
    [self.layer insertSublayer:gradient atIndex:0];

    self.coinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_wallet_coin"]];
    self.coinImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coinImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.coinImageView];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"My wallet";
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self addSubview:self.titleLabel];

    self.balanceLabel = [[UILabel alloc] init];
    self.balanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.balanceLabel.textColor = UIColor.whiteColor;
    self.balanceLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    self.balanceLabel.text = @"0";
    [self.balanceLabel setHidden:true];
    self.balanceLabel.adjustsFontSizeToFitWidth = YES;
    self.balanceLabel.minimumScaleFactor = 0.72;
    [self addSubview:self.balanceLabel];

    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_wallet_arrow"]];
    self.arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.arrowImageView];

    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor constraintEqualToConstant:82],

        [self.coinImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.coinImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.coinImageView.widthAnchor constraintEqualToConstant:56],
        [self.coinImageView.heightAnchor constraintEqualToConstant:56],

        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.coinImageView.trailingAnchor constant:24],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:24],
        [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.arrowImageView.leadingAnchor constant:-12],

        [self.balanceLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.balanceLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:2],
        [self.balanceLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.arrowImageView.leadingAnchor constant:-12],

        [self.arrowImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [self.arrowImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.arrowImageView.widthAnchor constraintEqualToConstant:36],
        [self.arrowImageView.heightAnchor constraintEqualToConstant:36]
    ]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CAGradientLayer *gradient = (CAGradientLayer *)[self.layer.sublayers firstObject];
    if ([gradient.name isEqualToString:@"lira_profile_wallet_gradient"]) {
        gradient.frame = self.bounds;
    }
}

- (void)configureWithUser:(LirauProfileUser *)user {
    NSString *balance = [self normalizedBalanceText:user.walletBalance];
    self.balanceLabel.text = balance.length > 0 ? balance : @"0";
    self.balanceLabel.accessibilityLabel = [NSString stringWithFormat:@"LiraU wallet balance %@", self.balanceLabel.text ?: @"0"];
}

- (NSString *)normalizedBalanceText:(NSString *)balance {
    if (![balance isKindOfClass:NSString.class]) {
        return @"0";
    }
    NSString *trimmed = [balance stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return trimmed.length > 0 ? trimmed : @"0";
}

@end
