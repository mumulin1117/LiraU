#import "LirauHomeViewController.h"
#import "LirauHomeHeaderView.h"
#import "LirauHomeSectionTitleView.h"
#import "LirauHomeUserChipView.h"
#import "LirauHomeTalkShowCell.h"
#import "LirauHomeWordBitsCell.h"
#import "LirauHomeManager.h"

@interface LirauHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LirauHomeHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *talkShowCollectionView;
@property (nonatomic, strong) UIStackView *userChipStackView;
@property (nonatomic, strong) UICollectionView *wordBitsCollectionView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) LirauHomeContent *homeContent;

@end

@implementation LirauHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.11 green:0.10 blue:0.18 alpha:1];
    [self buildView];
    [self loadHomeContent];
}

- (void)buildView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];

    self.headerView = [[LirauHomeHeaderView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.headerView.notificationHandler = ^{
        [weakSelf didTapNotification];
    };
    [self.contentView addSubview:self.headerView];

    LirauHomeSectionTitleView *talkTitle = [[LirauHomeSectionTitleView alloc] initWithImageName:@"lira_home_talkshow_mark"];
    [self.contentView addSubview:talkTitle];

    UICollectionViewFlowLayout *talkLayout = [[UICollectionViewFlowLayout alloc] init];
    talkLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    talkLayout.minimumLineSpacing = 14;
    talkLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.talkShowCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:talkLayout];
    self.talkShowCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.talkShowCollectionView.backgroundColor = UIColor.clearColor;
    self.talkShowCollectionView.showsHorizontalScrollIndicator = NO;
    self.talkShowCollectionView.dataSource = self;
    self.talkShowCollectionView.delegate = self;
    [self.talkShowCollectionView registerClass:LirauHomeTalkShowCell.class forCellWithReuseIdentifier:[LirauHomeTalkShowCell reuseIdentifier]];
    [self.contentView addSubview:self.talkShowCollectionView];

    self.userChipStackView = [[UIStackView alloc] init];
    self.userChipStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userChipStackView.axis = UILayoutConstraintAxisHorizontal;
    self.userChipStackView.spacing = 12;
    self.userChipStackView.distribution = UIStackViewDistributionFillEqually;
    [self.contentView addSubview:self.userChipStackView];

    LirauHomeSectionTitleView *wordTitle = [[LirauHomeSectionTitleView alloc] initWithImageName:@"lira_home_wordbits_mark"];
    [self.contentView addSubview:wordTitle];

    UICollectionViewFlowLayout *wordLayout = [[UICollectionViewFlowLayout alloc] init];
    wordLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    wordLayout.minimumLineSpacing = 12;
    wordLayout.sectionInset = UIEdgeInsetsZero;
    self.wordBitsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:wordLayout];
    self.wordBitsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.wordBitsCollectionView.backgroundColor = UIColor.clearColor;
    self.wordBitsCollectionView.scrollEnabled = NO;
    self.wordBitsCollectionView.dataSource = self;
    self.wordBitsCollectionView.delegate = self;
    [self.wordBitsCollectionView registerClass:LirauHomeWordBitsCell.class forCellWithReuseIdentifier:[LirauHomeWordBitsCell reuseIdentifier]];
    [self.contentView addSubview:self.wordBitsCollectionView];

    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingView.color = UIColor.whiteColor;
    [self.view addSubview:self.loadingView];

    self.stateLabel = [[UILabel alloc] init];
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.stateLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.stateLabel.textColor = [UIColor colorWithWhite:1 alpha:0.68];
    self.stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel.numberOfLines = 0;
    [self.view addSubview:self.stateLabel];

    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.retryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.retryButton setTitle:@"Retry" forState:UIControlStateNormal];
    [self.retryButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    self.retryButton.backgroundColor = [UIColor colorWithRed:0.72 green:0.24 blue:1 alpha:1];
    self.retryButton.layer.cornerRadius = 18;
    [self.retryButton addTarget:self action:@selector(loadHomeContent) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.hidden = YES;
    [self.view addSubview:self.retryButton];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],

        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],

        [self.headerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.headerView.heightAnchor constraintEqualToConstant:132],

        [talkTitle.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:-7],
        [talkTitle.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor constant:-50],
        [talkTitle.heightAnchor constraintEqualToConstant:32],

        [self.talkShowCollectionView.topAnchor constraintEqualToAnchor:talkTitle.bottomAnchor constant:10],
        [self.talkShowCollectionView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.talkShowCollectionView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.talkShowCollectionView.heightAnchor constraintEqualToConstant:282],

        [self.userChipStackView.topAnchor constraintEqualToAnchor:self.talkShowCollectionView.bottomAnchor constant:16],
        [self.userChipStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:50],
        [self.userChipStackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-50],
        [self.userChipStackView.heightAnchor constraintEqualToConstant:40],

        [wordTitle.topAnchor constraintEqualToAnchor:self.userChipStackView.bottomAnchor constant:27],
        [wordTitle.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [wordTitle.heightAnchor constraintEqualToConstant:32],

        [self.wordBitsCollectionView.topAnchor constraintEqualToAnchor:wordTitle.bottomAnchor constant:11],
        [self.wordBitsCollectionView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.wordBitsCollectionView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.wordBitsCollectionView.heightAnchor constraintEqualToConstant:212],
        [self.wordBitsCollectionView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-28],

        [self.loadingView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],

        [self.stateLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.stateLabel.topAnchor constraintEqualToAnchor:self.loadingView.bottomAnchor constant:12],
        [self.stateLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:24],
        [self.stateLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-24],

        [self.retryButton.topAnchor constraintEqualToAnchor:self.stateLabel.bottomAnchor constant:14],
        [self.retryButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.retryButton.widthAnchor constraintEqualToConstant:104],
        [self.retryButton.heightAnchor constraintEqualToConstant:36]
    ]];
}

- (void)loadHomeContent {
    [self setLoadingState];
    __weak typeof(self) weakSelf = self;
    [[LirauHomeManager sharedManager] loadHomeContentWithCompletion:^(LirauHomeContent *content, NSError *error, BOOL usedFallback) {
        [weakSelf.loadingView stopAnimating];
        weakSelf.homeContent = content;
        [weakSelf refreshUserChips];
        [weakSelf.talkShowCollectionView reloadData];
        [weakSelf.wordBitsCollectionView reloadData];

        BOOL empty = content.talkShowItems.count == 0 && content.wordBitsItems.count == 0;
        if (empty) {
            [weakSelf setEmptyState];
        } else if (usedFallback && error) {
            weakSelf.stateLabel.text = @"Showing local LiraU samples while home data refreshes.";
            weakSelf.retryButton.hidden = YES;
            weakSelf.scrollView.hidden = NO;
        } else {
            [weakSelf setLoadedState];
        }
    }];
}

- (void)setLoadingState {
    self.scrollView.hidden = YES;
    self.retryButton.hidden = YES;
    self.stateLabel.text = @"Loading LiraU home...";
    [self.loadingView startAnimating];
}

- (void)setLoadedState {
    self.scrollView.hidden = NO;
    self.retryButton.hidden = YES;
    self.stateLabel.text = @"";
}

- (void)setEmptyState {
    self.scrollView.hidden = YES;
    self.retryButton.hidden = NO;
    self.stateLabel.text = @"No LiraU home content yet.";
}

- (void)refreshUserChips {
    for (UIView *view in self.userChipStackView.arrangedSubviews) {
        [self.userChipStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    NSUInteger count = MIN(self.homeContent.recommendations.count, 2);
    for (NSUInteger index = 0; index < count; index++) {
        LirauHomeUserChipView *chipView = [[LirauHomeUserChipView alloc] init];
        [chipView configureWithRecommendation:self.homeContent.recommendations[index]];
        chipView.tag = index;
        [chipView addTarget:self action:@selector(didTapUserChip:) forControlEvents:UIControlEventTouchUpInside];
        [self.userChipStackView addArrangedSubview:chipView];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.talkShowCollectionView) {
        return self.homeContent.talkShowItems.count;
    }
    return self.homeContent.wordBitsItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.talkShowCollectionView) {
        LirauHomeTalkShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LirauHomeTalkShowCell reuseIdentifier] forIndexPath:indexPath];
        [cell configureWithItem:self.homeContent.talkShowItems[indexPath.item] highlightedCard:indexPath.item == 0];
        return cell;
    }

    LirauHomeWordBitsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LirauHomeWordBitsCell reuseIdentifier] forIndexPath:indexPath];
    [cell configureWithItem:self.homeContent.wordBitsItems[indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.talkShowCollectionView) {
        CGFloat width = MIN(240, CGRectGetWidth(self.view.bounds) - 96);
        return CGSizeMake(width, 280);
    }
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.talkShowCollectionView) {
        NSLog(@"LiraU Home TODO: TalkShow card tapped at index %ld", (long)indexPath.item);
        // TODO: Open Home detail page after the detail module is implemented.
        return;
    }
    NSLog(@"LiraU Home TODO: WordBits card tapped at index %ld", (long)indexPath.item);
    // TODO: Open H5 page after Web module is implemented.
}

- (void)didTapUserChip:(LirauHomeUserChipView *)sender {
    NSLog(@"LiraU Home TODO: User chip tapped at index %ld", (long)sender.tag);
    // TODO: Open user profile detail after the profile detail module is implemented.
}

- (void)didTapNotification {
    NSLog(@"LiraU Home TODO: Notification entry tapped");
    // TODO: Open notification page after the message module is implemented.
}

@end
