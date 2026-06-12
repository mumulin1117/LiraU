#import "LirauProfileIntroLorauaViewController.h"
#import "LirauProfileIntroLorauaHeaderView.h"
#import "LirauVirtualCurrencyLorauaWalletView.h"
#import "LirauProfileIntroLorauaEmptyView.h"
#import "LirauNarrativeSharingLorauaPostCell.h"
#import "LirauProfileIntroLorauaManager.h"
#import "LirauLnBuor-Swift.h"

typedef NS_ENUM(NSInteger, LirauContentCurationLorauaSegment) {
    LirauContentCurationLorauaSegmentPosts,
    LirauContentCurationLorauaSegmentCollections,
    LirauContentCurationLorauaSegmentLikes
};

@interface LirauProfileIntroLorauaViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LirauProfileIntroLorauaHeaderView *headerView;
@property (nonatomic, strong) LirauVirtualCurrencyLorauaWalletView *walletView;
@property (nonatomic, strong) UIStackView *segmentStackView;
@property (nonatomic, strong) NSArray<UIButton *> *segmentButtons;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LirauProfileIntroLorauaEmptyView *emptyView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSLayoutConstraint *collectionHeightConstraint;
@property (nonatomic, strong) LirauProfileIntroLorauaContent *profileIntroLorauaContent;
@property (nonatomic, assign) LirauContentCurationLorauaSegment selectedSegment;

@end

@implementation LirauProfileIntroLorauaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.114 green:0.106 blue:0.180 alpha:1];
    self.selectedSegment = LirauContentCurationLorauaSegmentPosts;
    [self setupViews];
    [self loadProfileIntroLorauaContent];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateProfileIntroLorauaCollectionHeight];
}

- (void)setupViews {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];

    self.headerView = [[LirauProfileIntroLorauaHeaderView alloc] init];
    [self.contentView addSubview:self.headerView];

    __weak typeof(self) weakSelf = self;
    self.headerView.settingsHandler = ^{
        [weakSelf handlePrivacySettingsLorauaTap];
    };
    self.headerView.editHandler = ^{
        [weakSelf handleProfileIntroLorauaEditTap];
    };
    self.headerView.statHandler = ^(NSString *statName) {
        [weakSelf handleProfileIntroLorauaStatTap:statName];
    };

    self.walletView = [[LirauVirtualCurrencyLorauaWalletView alloc] init];
    [self.walletView addTarget:self action:@selector(handleVirtualCurrencyLorauaWalletTap) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.walletView];

    self.segmentStackView = [[UIStackView alloc] init];
    self.segmentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentStackView.axis = UILayoutConstraintAxisHorizontal;
    self.segmentStackView.alignment = UIStackViewAlignmentCenter;
    self.segmentStackView.distribution = UIStackViewDistributionFillEqually;
    self.segmentStackView.spacing = 8;
    [self.contentView addSubview:self.segmentStackView];

    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    NSArray *titles = @[@"POSTS", @"SAVED", @"LIKES"];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = idx;
        button.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightHeavy];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handleContentCurationLorauaSegmentTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.segmentStackView addArrangedSubview:button];
        [buttons addObject:button];
    }];
    self.segmentButtons = [buttons copy];
    [self updateContentCurationLorauaSegmentAppearance];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 16;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:LirauNarrativeSharingLorauaPostCell.class forCellWithReuseIdentifier:[LirauNarrativeSharingLorauaPostCell narrativeSharingLorauaReuseIdentifier]];
    [self.contentView addSubview:self.collectionView];

    self.emptyView = [[LirauProfileIntroLorauaEmptyView alloc] init];
    [self.emptyView configureWithProfileIntroLorauaText:@"No profile posts yet. Share a language moment from Home or Video later."];
    self.emptyView.hidden = YES;
    [self.contentView addSubview:self.emptyView];

    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingView.color = UIColor.whiteColor;
    [self.contentView addSubview:self.loadingView];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.textColor = [UIColor colorWithWhite:1 alpha:0.68];
    self.statusLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    [self.contentView addSubview:self.statusLabel];

    self.collectionHeightConstraint = [self.collectionView.heightAnchor constraintEqualToConstant:0];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-24],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],

        [self.headerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.headerView.heightAnchor constraintGreaterThanOrEqualToConstant:250],

        [self.walletView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:16],
        [self.walletView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.walletView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],

        [self.segmentStackView.topAnchor constraintEqualToAnchor:self.walletView.bottomAnchor constant:28],
        [self.segmentStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.segmentStackView.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.segmentStackView.heightAnchor constraintEqualToConstant:36],

        [self.collectionView.topAnchor constraintEqualToAnchor:self.segmentStackView.bottomAnchor constant:12],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        self.collectionHeightConstraint,

        [self.emptyView.topAnchor constraintEqualToAnchor:self.segmentStackView.bottomAnchor constant:12],
        [self.emptyView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.emptyView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.emptyView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-18],

        [self.collectionView.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-18],

        [self.loadingView.topAnchor constraintEqualToAnchor:self.segmentStackView.bottomAnchor constant:32],
        [self.loadingView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],

        [self.statusLabel.topAnchor constraintEqualToAnchor:self.loadingView.bottomAnchor constant:10],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:24],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-24]
    ]];
}

- (void)loadProfileIntroLorauaContent {
    [self.loadingView startAnimating];
    self.statusLabel.text = @"Loading profile...";
    [[LirauProfileIntroLorauaManager sharedProfileIntroLorauaManager] loadProfileIntroLorauaContentWithCompletion:^(LirauProfileIntroLorauaContent *content, NSError *error, BOOL usedFallback, BOOL calledRemoteProfile) {
        self.profileIntroLorauaContent = content;
        [self.headerView configureWithGlobalCitizenLorauaProfile:content.globalCitizenLorauaProfile];
        [self.walletView configureWithGlobalCitizenLorauaProfile:content.globalCitizenLorauaProfile];
        if (error && usedFallback) {
            self.statusLabel.text = @"Showing local profile.";
        } else {
            self.statusLabel.text = @"";
        }
        [self.loadingView stopAnimating];
        [self.collectionView reloadData];
        [self updateProfileIntroLorauaContentState];
    }];
}

- (NSArray<LirauNarrativeSharingLorauaPost *> *)visibleNarrativeSharingLorauaPosts {
    if (self.selectedSegment != LirauContentCurationLorauaSegmentPosts) {
        return @[];
    }
    return self.profileIntroLorauaContent.posts ?: @[];
}

- (void)updateProfileIntroLorauaContentState {
    BOOL hasPosts = self.visibleNarrativeSharingLorauaPosts.count > 0;
    self.collectionView.hidden = !hasPosts;
    self.emptyView.hidden = hasPosts;
    if (self.selectedSegment == LirauContentCurationLorauaSegmentCollections) {
        [self.emptyView configureWithProfileIntroLorauaText:@"Saved language moments will appear here."];
    } else if (self.selectedSegment == LirauContentCurationLorauaSegmentLikes) {
        [self.emptyView configureWithProfileIntroLorauaText:@"Liked posts will appear here."];
    } else {
        [self.emptyView configureWithProfileIntroLorauaText:@"No profile posts yet. Share a language moment from Home or Video later."];
    }
    [self updateProfileIntroLorauaCollectionHeight];
}

- (void)updateProfileIntroLorauaCollectionHeight {
    if (!self.collectionHeightConstraint) {
        return;
    }
    NSInteger count = self.visibleNarrativeSharingLorauaPosts.count;
    if (count == 0) {
        self.collectionHeightConstraint.constant = 0;
        return;
    }
    CGFloat width = CGRectGetWidth(self.view.bounds) - 32;
    CGFloat cardHeight = MAX(220, width * 0.70);
    self.collectionHeightConstraint.constant = count * cardHeight + MAX(0, count - 1) * 16;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)updateContentCurationLorauaSegmentAppearance {
    [self.segmentButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        BOOL selected = idx == self.selectedSegment;
        [button setTitleColor:selected ? UIColor.whiteColor : [UIColor colorWithWhite:1 alpha:0.38] forState:UIControlStateNormal];
    }];
}

- (void)handlePrivacySettingsLorauaTap {
    NSLog(@"LiraU Profile settings tapped");
    [self openProfileIntroLorauaWebPath:[LirauDeepLinkingLorauaRoute privacySettingsLorauaSettingsPath]];
}

- (void)handleProfileIntroLorauaEditTap {
    NSLog(@"LiraU Profile edit tapped");
    [self openProfileIntroLorauaWebPath:[LirauDeepLinkingLorauaRoute profileIntroLorauaEditPath]];
}

- (void)handleVirtualCurrencyLorauaWalletTap {
    NSLog(@"LiraU Profile wallet tapped");
    [self openProfileIntroLorauaWebPath:[LirauDeepLinkingLorauaRoute virtualCurrencyLorauaWalletPath]];
}

- (void)handleProfileIntroLorauaStatTap:(NSString *)statName {
    NSLog(@"LiraU Profile stat tapped: %@", statName);
    if ([statName isEqualToString:@"Following"]) {
        [self openProfileIntroLorauaWebPath:[LirauDeepLinkingLorauaRoute globalCommunityLorauaRelationListPathWithType:1]];
    } else if ([statName isEqualToString:@"Followers"]) {
        [self openProfileIntroLorauaWebPath:[LirauDeepLinkingLorauaRoute globalCommunityLorauaRelationListPathWithType:2]];
    } else if ([statName isEqualToString:@"Post"]) {
        NSString *globalCitizenLorauaID = self.profileIntroLorauaContent.globalCitizenLorauaProfile.globalCitizenLorauaID ?: @"";
        [self openProfileIntroLorauaWebPath:[LirauDeepLinkingLorauaRoute languageExchangePartnerLorauaProfilePathWithUserID:globalCitizenLorauaID]];
    }
}

- (void)handleContentCurationLorauaSegmentTap:(UIButton *)sender {
    self.selectedSegment = sender.tag;
    NSLog(@"LiraU Profile segment tapped: %@", sender.currentTitle ?: @"");
    // TODO: Load saved or liked profile content after those data sources are implemented.
    [self updateContentCurationLorauaSegmentAppearance];
    [self.collectionView reloadData];
    [self updateProfileIntroLorauaContentState];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.visibleNarrativeSharingLorauaPosts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LirauNarrativeSharingLorauaPostCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LirauNarrativeSharingLorauaPostCell narrativeSharingLorauaReuseIdentifier] forIndexPath:indexPath];
    [cell configureWithNarrativeSharingLorauaPost:self.visibleNarrativeSharingLorauaPosts[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LirauNarrativeSharingLorauaPost *post = self.visibleNarrativeSharingLorauaPosts[indexPath.item];
    NSLog(@"LiraU Profile post tapped: %@", post.title);
    [self openProfileIntroLorauaWebPath:[LirauDeepLinkingLorauaRoute narrativeSharingLorauaDynamicDetailPathWithDynamicID:post.postID]];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(width, MAX(220, width * 0.70));
}

- (void)openProfileIntroLorauaWebPath:(NSString *)path {
    if (path.length == 0) {
        return;
    }
    LirauDeepLinkingLorauaPortalViewController *controller = [[LirauDeepLinkingLorauaPortalViewController alloc] initWithDeepLinkingLorauaEntryURLString:path];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
