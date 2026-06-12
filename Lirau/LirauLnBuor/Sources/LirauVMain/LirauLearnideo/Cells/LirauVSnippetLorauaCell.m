#import "LirauVSnippetLorauaCell.h"
#import "LirauLanguageExchangePartnerLorauaBadgeView.h"
#import "LirauAudienceEngagementLorauaActionBarView.h"

@interface LirauVSnippetLorauaCell ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) LirauLanguageExchangePartnerLorauaBadgeView *userBadgeView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) LirauAudienceEngagementLorauaActionBarView *actionBarView;
@property (nonatomic, strong) CAGradientLayer *placeholderLayer;
@property (nonatomic, strong) CAGradientLayer *bottomShadeLayer;
@property (nonatomic, copy) NSString *currentCoverURLString;

@end

@implementation LirauVSnippetLorauaCell

+ (NSString *)videoSnippetLorauaReuseIdentifier {
    return @"LirauVideoSnippetLorauaCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildDiscoveryFeedLorauaView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverImageView.image = nil;
    self.currentCoverURLString = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderLayer.frame = self.contentView.bounds;
    self.bottomShadeLayer.frame = self.contentView.bounds;
}

- (void)buildDiscoveryFeedLorauaView {
    self.contentView.backgroundColor = [UIColor colorWithRed:0.11 green:0.10 blue:0.18 alpha:1];
    self.contentView.clipsToBounds = YES;

    self.placeholderLayer = [CAGradientLayer layer];
    self.placeholderLayer.colors = @[
        (__bridge id)[UIColor colorWithRed:0.26 green:0.23 blue:0.36 alpha:1].CGColor,
        (__bridge id)[UIColor colorWithRed:0.08 green:0.07 blue:0.13 alpha:1].CGColor
    ];
    self.placeholderLayer.startPoint = CGPointMake(0, 0);
    self.placeholderLayer.endPoint = CGPointMake(1, 1);
    [self.contentView.layer addSublayer:self.placeholderLayer];

    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.coverImageView];

    self.bottomShadeLayer = [CAGradientLayer layer];
    self.bottomShadeLayer.colors = @[
        (__bridge id)[UIColor clearColor].CGColor,
        (__bridge id)[UIColor colorWithWhite:0 alpha:0.56].CGColor
    ];
    self.bottomShadeLayer.startPoint = CGPointMake(0.5, 0.42);
    self.bottomShadeLayer.endPoint = CGPointMake(0.5, 1);
    [self.contentView.layer addSublayer:self.bottomShadeLayer];

    UIControl *videoTapControl = [[UIControl alloc] init];
    videoTapControl.translatesAutoresizingMaskIntoConstraints = NO;
    [videoTapControl addTarget:self action:@selector(didTapVideoSnippetLoraua) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:videoTapControl];

    self.userBadgeView = [[LirauLanguageExchangePartnerLorauaBadgeView alloc] init];
    [self.userBadgeView addTarget:self action:@selector(didTapLanguageExchangePartnerLoraua) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.userBadgeView];

    self.reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reportButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.reportButton.backgroundColor = nil;
    [self.reportButton setImage:[UIImage imageNamed:@"lira_video_alert_button"] forState:UIControlStateNormal];
    [self.reportButton addTarget:self action:@selector(didTapReportSystemLoraua) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.reportButton];

    self.playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lira_video_play_button"]];
    self.playImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.playImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.playImageView];

    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.descriptionLabel.textColor = UIColor.whiteColor;
    self.descriptionLabel.numberOfLines = 2;
    self.descriptionLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.22];
    self.descriptionLabel.layer.cornerRadius = 20;
    self.descriptionLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.descriptionLabel];

    self.actionBarView = [[LirauAudienceEngagementLorauaActionBarView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.actionBarView.audienceEngagementLorauaLikeHandler = ^{ if (weakSelf.audienceEngagementLorauaLikeHandler) { weakSelf.audienceEngagementLorauaLikeHandler(); } };
    self.actionBarView.audienceEngagementLorauaCommentHandler = ^{ if (weakSelf.audienceEngagementLorauaCommentHandler) { weakSelf.audienceEngagementLorauaCommentHandler(); } };
    [self.contentView addSubview:self.actionBarView];

    [NSLayoutConstraint activateConstraints:@[
        [self.coverImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.coverImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.coverImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.coverImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [videoTapControl.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [videoTapControl.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [videoTapControl.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [videoTapControl.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],

        [self.userBadgeView.topAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.topAnchor constant:104],
        [self.userBadgeView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.userBadgeView.widthAnchor constraintGreaterThanOrEqualToConstant:130],
        [self.userBadgeView.widthAnchor constraintLessThanOrEqualToConstant:210],

        [self.reportButton.centerYAnchor constraintEqualToAnchor:self.userBadgeView.centerYAnchor],
        [self.reportButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.reportButton.widthAnchor constraintEqualToConstant:30],
        [self.reportButton.heightAnchor constraintEqualToConstant:30],

        [self.playImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.playImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.playImageView.widthAnchor constraintEqualToConstant:80],
        [self.playImageView.heightAnchor constraintEqualToConstant:80],

        [self.actionBarView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.actionBarView.bottomAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.bottomAnchor constant:-76],
        [self.actionBarView.widthAnchor constraintEqualToConstant:44],

        [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.descriptionLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.actionBarView.leadingAnchor constant:-16],
        [self.descriptionLabel.bottomAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.bottomAnchor constant:-72],
        [self.descriptionLabel.heightAnchor constraintGreaterThanOrEqualToConstant:52]
    ]];
}

- (void)configureWithNarrativeSharingLorauaItem:(LirauVSnippetLorauaItem *)item {
    [self.userBadgeView configureWithNarrativeSharingLorauaItem:item];
    self.descriptionLabel.text = [NSString stringWithFormat:@"  %@", [item videoSnippetLorauaDisplayDescription]];
    [self.actionBarView configureWithNarrativeSharingLorauaItem:item];
    self.currentCoverURLString = [item videoSnippetLorauaDisplayCoverURLString];
    [self loadImageFromURLString:self.currentCoverURLString];
}

- (void)loadImageFromURLString:(NSString *)urlString {
    if (urlString.length == 0) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || data.length == 0) {
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.currentCoverURLString isEqualToString:urlString]) {
                weakSelf.coverImageView.image = image;
            }
        });
    }] resume];
}

- (void)didTapLanguageExchangePartnerLoraua {
    if (self.languageExchangePartnerLorauaHandler) {
        self.languageExchangePartnerLorauaHandler();
    }
}

- (void)didTapVideoSnippetLoraua {
    if (self.videoSnippetLorauaHandler) {
        self.videoSnippetLorauaHandler();
    }
}

- (void)didTapReportSystemLoraua {
    if (self.reportSystemLorauaHandler) {
        self.reportSystemLorauaHandler();
        return;
    }
    NSLog(@"LiraU Video TODO: Report entry tapped");
    // TODO: Open report or more panel after the moderation module is implemented.
}

@end
