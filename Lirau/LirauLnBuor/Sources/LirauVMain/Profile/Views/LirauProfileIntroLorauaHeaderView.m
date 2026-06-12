#import "LirauProfileIntroLorauaHeaderView.h"

@interface LirauProfileIntroLorauaHeaderView ()

@property (nonatomic, strong) UIImageView *waveImageView;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIStackView *statsStackView;
@property (nonatomic, strong) NSArray<UILabel *> *valueLabels;

@end

@implementation LirauProfileIntroLorauaHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];

    self.waveImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_header_wave"]];
    self.waveImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.waveImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.waveImageView];

    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.settingsButton.backgroundColor = UIColor.whiteColor;
    self.settingsButton.layer.cornerRadius = 16;
    [self.settingsButton setImage:[UIImage imageNamed:@"lira_profile_settings_icon"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(didTapSettings) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.settingsButton];

    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.editButton.backgroundColor = UIColor.whiteColor;
    self.editButton.layer.cornerRadius = 16;
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.editButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(didTapEdit) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.editButton];

    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_profile_avatar_default"]];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 40;
    [self addSubview:self.avatarImageView];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.textColor = UIColor.whiteColor;
    self.nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.minimumScaleFactor = 0.8;
    [self addSubview:self.nameLabel];

    self.statsStackView = [[UIStackView alloc] init];
    self.statsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.statsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.statsStackView.distribution = UIStackViewDistributionFillEqually;
    self.statsStackView.alignment = UIStackViewAlignmentCenter;
    self.statsStackView.spacing = 8;
    [self addSubview:self.statsStackView];

    NSMutableArray<UILabel *> *valueLabels = [NSMutableArray array];
    NSArray *titles = @[@"Following", @"Post", @"Followers"];
    for (NSString *title in titles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.accessibilityLabel = title;
        [button addTarget:self action:@selector(didTapStat:) forControlEvents:UIControlEventTouchUpInside];

        UIStackView *stack = [[UIStackView alloc] init];
        stack.translatesAutoresizingMaskIntoConstraints = NO;
        stack.axis = UILayoutConstraintAxisVertical;
        stack.alignment = UIStackViewAlignmentCenter;
        stack.spacing = 6;
        stack.userInteractionEnabled = NO;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title;
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = 0.75;

        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.textColor = UIColor.whiteColor;
        valueLabel.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.minimumScaleFactor = 0.75;
        [valueLabels addObject:valueLabel];

        [stack addArrangedSubview:titleLabel];
        [stack addArrangedSubview:valueLabel];
        [button addSubview:stack];
        [self.statsStackView addArrangedSubview:button];

        [NSLayoutConstraint activateConstraints:@[
            [stack.leadingAnchor constraintEqualToAnchor:button.leadingAnchor],
            [stack.trailingAnchor constraintEqualToAnchor:button.trailingAnchor],
            [stack.centerYAnchor constraintEqualToAnchor:button.centerYAnchor],
            [button.heightAnchor constraintGreaterThanOrEqualToConstant:58]
        ]];
    }
    self.valueLabels = [valueLabels copy];

    [NSLayoutConstraint activateConstraints:@[
        [self.waveImageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.waveImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.waveImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.waveImageView.heightAnchor constraintEqualToConstant:132],

        [self.settingsButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:53],
        [self.settingsButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.settingsButton.widthAnchor constraintEqualToConstant:32],
        [self.settingsButton.heightAnchor constraintEqualToConstant:32],

        [self.editButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:53],
        [self.editButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.editButton.widthAnchor constraintEqualToConstant:68],
        [self.editButton.heightAnchor constraintEqualToConstant:32],

        [self.avatarImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.avatarImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:53],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:80],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:80],

        [self.nameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor constant:10],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:24],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24],

        [self.statsStackView.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:20],
        [self.statsStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:40],
        [self.statsStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-40],
        [self.statsStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8]
    ]];
}

- (void)configureWithGlobalCitizenLorauaProfile:(LirauGlobalCitizenLorauaProfile *)profile {
    self.nameLabel.text = profile.nativeSpeakerLorauaName.length > 0 ? profile.nativeSpeakerLorauaName : @"LiraU Learner";
    NSArray *values = @[@(profile.peerLearningLorauaFollowingCount), @(profile.narrativeSharingLorauaPostCount), @(profile.globalCommunityLorauaFollowersCount)];
    [self.valueLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.text = [NSString stringWithFormat:@"%@", values[idx]];
    }];
    [self loadAvatar:profile.avatarChatLorauaURLString];
}

- (void)loadAvatar:(NSString *)urlString {
    self.avatarImageView.image = [UIImage imageNamed:@"lira_profile_avatar_default"];
    NSURL *url = [NSURL URLWithString:urlString ?: @""];
    if (!url) {
        return;
    }
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = data.length > 0 ? [UIImage imageWithData:data] : nil;
        if (!image) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = image;
        });
    }];
    [task resume];
}

- (void)didTapSettings {
    if (self.settingsHandler) {
        self.settingsHandler();
    }
}

- (void)didTapEdit {
    if (self.editHandler) {
        self.editHandler();
    }
}

- (void)didTapStat:(UIButton *)sender {
    if (self.statHandler) {
        self.statHandler(sender.accessibilityLabel ?: @"");
    }
}

@end
