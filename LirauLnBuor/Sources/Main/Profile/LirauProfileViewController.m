#import "LirauProfileViewController.h"
#import "LirauProfileHeaderView.h"
#import "LirauProfileWalletView.h"
#import "LirauProfileEmptyView.h"
#import "LirauProfilePostCell.h"
#import "LirauProfileManager.h"

typedef NS_ENUM(NSInteger, LirauProfileSegment) {
    LirauProfileSegmentPosts,
    LirauProfileSegmentCollections,
    LirauProfileSegmentLikes
};

@interface LirauProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LirauProfileHeaderView *headerView;
@property (nonatomic, strong) LirauProfileWalletView *walletView;
@property (nonatomic, strong) UIStackView *segmentStackView;
@property (nonatomic, strong) NSArray<UIButton *> *segmentButtons;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LirauProfileEmptyView *emptyView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSLayoutConstraint *collectionHeightConstraint;
@property (nonatomic, strong) LirauProfileContent *profileContent;
@property (nonatomic, assign) LirauProfileSegment selectedSegment;

@end

@implementation LirauProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.114 green:0.106 blue:0.180 alpha:1];
    self.selectedSegment = LirauProfileSegmentPosts;
    [self setupViews];
    [self loadProfileContent];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateCollectionHeight];
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

    self.headerView = [[LirauProfileHeaderView alloc] init];
    [self.contentView addSubview:self.headerView];

    __weak typeof(self) weakSelf = self;
    self.headerView.settingsHandler = ^{
        [weakSelf handleSettingsTap];
    };
    self.headerView.editHandler = ^{
        [weakSelf handleEditTap];
    };
    self.headerView.statHandler = ^(NSString *statName) {
        [weakSelf handleStatTap:statName];
    };

    self.walletView = [[LirauProfileWalletView alloc] init];
    [self.walletView addTarget:self action:@selector(handleWalletTap) forControlEvents:UIControlEventTouchUpInside];
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
        [button addTarget:self action:@selector(handleSegmentTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.segmentStackView addArrangedSubview:button];
        [buttons addObject:button];
    }];
    self.segmentButtons = [buttons copy];
    [self updateSegmentAppearance];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 16;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:LirauProfilePostCell.class forCellWithReuseIdentifier:[LirauProfilePostCell reuseIdentifier]];
    [self.contentView addSubview:self.collectionView];

    self.emptyView = [[LirauProfileEmptyView alloc] init];
    [self.emptyView configureWithText:@"No profile posts yet. Share a language moment from Home or Video later."];
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

- (void)loadProfileContent {
    [self.loadingView startAnimating];
    self.statusLabel.text = @"Loading profile...";
    [[LirauProfileManager sharedManager] loadProfileContentWithCompletion:^(LirauProfileContent *content, NSError *error, BOOL usedFallback, BOOL calledRemoteProfile) {
        self.profileContent = content;
        [self.headerView configureWithUser:content.user];
        [self.walletView configureWithUser:content.user];
        if (error && usedFallback) {
            self.statusLabel.text = @"Showing local profile.";
        } else {
            self.statusLabel.text = @"";
        }
        [self.loadingView stopAnimating];
        [self.collectionView reloadData];
        [self updateContentState];
    }];
}

- (NSArray<LirauProfilePost *> *)visiblePosts {
    if (self.selectedSegment != LirauProfileSegmentPosts) {
        return @[];
    }
    return self.profileContent.posts ?: @[];
}

- (void)updateContentState {
    BOOL hasPosts = self.visiblePosts.count > 0;
    self.collectionView.hidden = !hasPosts;
    self.emptyView.hidden = hasPosts;
    if (self.selectedSegment == LirauProfileSegmentCollections) {
        [self.emptyView configureWithText:@"Saved language moments will appear here."];
    } else if (self.selectedSegment == LirauProfileSegmentLikes) {
        [self.emptyView configureWithText:@"Liked posts will appear here."];
    } else {
        [self.emptyView configureWithText:@"No profile posts yet. Share a language moment from Home or Video later."];
    }
    [self updateCollectionHeight];
}

- (void)updateCollectionHeight {
    if (!self.collectionHeightConstraint) {
        return;
    }
    NSInteger count = self.visiblePosts.count;
    if (count == 0) {
        self.collectionHeightConstraint.constant = 0;
        return;
    }
    CGFloat width = CGRectGetWidth(self.view.bounds) - 32;
    CGFloat cardHeight = MAX(220, width * 0.70);
    self.collectionHeightConstraint.constant = count * cardHeight + MAX(0, count - 1) * 16;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)updateSegmentAppearance {
    [self.segmentButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        BOOL selected = idx == self.selectedSegment;
        [button setTitleColor:selected ? UIColor.whiteColor : [UIColor colorWithWhite:1 alpha:0.38] forState:UIControlStateNormal];
    }];
}

- (void)handleSettingsTap {
    NSLog(@"LiraU Profile settings tapped");
    // TODO: Open profile settings after Settings module is implemented.
}

- (void)handleEditTap {
    NSLog(@"LiraU Profile edit tapped");
    // TODO: Open edit profile after Profile Edit module is implemented.
}

- (void)handleWalletTap {
    NSLog(@"LiraU Profile wallet tapped");
    // TODO: Open wallet after Wallet module is implemented.
}

- (void)handleStatTap:(NSString *)statName {
    NSLog(@"LiraU Profile stat tapped: %@", statName);
    // TODO: Open following/followers/post list after Relation module is implemented.
}

- (void)handleSegmentTap:(UIButton *)sender {
    self.selectedSegment = sender.tag;
    NSLog(@"LiraU Profile segment tapped: %@", sender.currentTitle ?: @"");
    // TODO: Load saved or liked profile content after those data sources are implemented.
    [self updateSegmentAppearance];
    [self.collectionView reloadData];
    [self updateContentState];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.visiblePosts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LirauProfilePostCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LirauProfilePostCell reuseIdentifier] forIndexPath:indexPath];
    [cell configureWithPost:self.visiblePosts[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LirauProfilePost *post = self.visiblePosts[indexPath.item];
    NSLog(@"LiraU Profile post tapped: %@", post.title);
    // TODO: Open profile post detail after Detail module is implemented.
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(width, MAX(220, width * 0.70));
}

@end
